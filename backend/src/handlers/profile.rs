use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, ColumnTrait, EntityTrait, QueryFilter, Set, TransactionTrait};
use validator::Validate;

use crate::entity::profile_verification_codes::{self};
use crate::entity::profiles::{self, Entity as Profile};
use crate::model;
use crate::model::api::response::ProfileResponse;
use crate::utils::resend::create_profile_verification_email;
use crate::{AppState, utils::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Get the profile of the authenticated user",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = ProfileResponse),
        (status = 403, description = "Forbidden - Profile is not verified", body = model::api::error::ProfileNotVerifiedError),
        (status = 404, description = "The profile was not found. Have you remembered to create it first?", body = model::api::error::NotFoundError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = model::api::error::UnauthorizedError),
        (status = 500, description = "Internal server error", body = model::api::error::InternalServerError),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn get_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<ProfileResponse>, Response> {
    // Query the database for the user's profile
    let maybe_profile = Profile::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    let Some(profile) = maybe_profile else {
        tracing::warn!("Profile not found for user {}", claims.user_id);
        return Err(model::api::error::ErrorResponse::not_found(Some(
            "Profile not found. Have you remembered to create it first?",
        )));
    };

    if !profile.verified {
        tracing::warn!("Profile for user {} is not verified", claims.user_id);
        return Err(model::api::error::ErrorResponse::profile_not_verified());
    }

    Ok(Json(profile.into()))
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Create a profile for the authenticated user",
    responses(
        (status = 200, description = "User profile created successfully", body = ProfileResponse),
        (status = 400, description = "Invalid request payload or email not provided in token claims", body = model::api::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = model::api::error::UnauthorizedError),
        (status = 409, description = "Profile already exists", body = model::api::error::ConflictError),
        (status = 500, description = "Internal server error", body = model::api::error::InternalServerError),
    ),
    request_body = model::api::profile::CreateProfileRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<model::api::profile::CreateProfileRequest>,
) -> Result<Json<ProfileResponse>, Response> {
    // Verify request validity
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid create profile request: {}", e);
        return Err(model::api::error::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Check if profile already exists
    let exists = Profile::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    if exists.is_some() {
        return Err(model::api::error::ErrorResponse::conflict(Some(
            "Profile already exists",
        )));
    }

    // Email might not be present in all claims
    if claims.email.is_none() {
        return Err(model::api::error::ErrorResponse::bad_request(Some(
            "Email was not provided in token claims",
        )));
    }

    let new_profile = profiles::ActiveModel {
        id: Set(claims.user_id.clone()),
        email: Set(claims.email.unwrap()),
        first_name: Set(payload.first_name.clone()),
        last_name: Set(payload.last_name.clone()),
        ..Default::default()
    };

    let tsx = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    let profile = new_profile.insert(&tsx).await.map_err(|e| {
        tracing::error!("Database insert failed: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    let code_as_int = rand::random_range(0..=999999);

    let code = format!("{:06}", code_as_int);

    tracing::info!(
        "Generated verification code {} for user {}",
        code,
        claims.user_id
    );

    let email = create_profile_verification_email(&profile.email, code.as_str());

    if let Err(e) = state.resend.emails.send(email).await {
        tracing::error!("Failed to send profile verification email: {}", e);
        if let Err(rollback_err) = tsx.rollback().await {
            tracing::error!(
                "FAILED TO ROLLBACK TRANSACTION! THIS IS VERY BAD: {}",
                rollback_err
            );
        }
        return Err(model::api::error::ErrorResponse::internal_server_error());
    };

    let code = profile_verification_codes::ActiveModel {
        code: Set(code),
        profile_id: Set(claims.user_id),
        ..Default::default()
    };

    if let Err(e) = code.insert(&tsx).await {
        tracing::error!("Failed to insert profile verification code: {}", e);
        if let Err(rollback_err) = tsx.rollback().await {
            tracing::error!(
                "FAILED TO ROLLBACK TRANSACTION! THIS IS VERY BAD: {}",
                rollback_err
            );
        }
        return Err(model::api::error::ErrorResponse::internal_server_error());
    };

    tsx.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(profile.into()))
}

#[utoipa::path(
    post,
    path = "/api/auth/profile/verify",
    tag = "profile",
    description = "Verify the authenticated user's profile using a verification code sent to their email",
    responses(
        (status = 200, description = "Profile verified successfully", body = ProfileResponse),
        (status = 400, description = "Invalid or expired verification code, or invalid request payload", body = model::api::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = model::api::error::UnauthorizedError),
        (status = 404, description = "Profile not found", body = model::api::error::NotFoundError),
        (status = 500, description = "Internal server error", body = model::api::error::InternalServerError),
    ),
    request_body = model::api::profile::VerifyProfileRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn verify_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<model::api::profile::VerifyProfileRequest>,
) -> Result<Json<ProfileResponse>, Response> {
    // Verify request validity
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid verify profile request: {}", e);
        return Err(model::api::error::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Additional validation: ensure code is numeric
    if !payload.is_valid_code() {
        tracing::warn!("Verification code contains non-numeric characters");
        return Err(model::api::error::ErrorResponse::bad_request(Some(
            "Verification code must be numeric",
        )));
    }

    let user_id = &claims.user_id;

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Find valid code in database
    let code = profile_verification_codes::Entity::find()
        .filter(profile_verification_codes::Column::ProfileId.eq(user_id))
        .filter(profile_verification_codes::Column::Code.eq(payload.code.clone()))
        .filter(profile_verification_codes::Column::Expiration.gt(chrono::Utc::now()))
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Invalid or expired verification code for user {}", user_id);
            model::api::error::ErrorResponse::bad_request(Some(
                "Invalid or expired verification code",
            ))
        })?;

    // Find profile associated with the verification code
    let mut profile: profiles::ActiveModel = Profile::find_by_id(&code.profile_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            model::api::error::ErrorResponse::not_found(Some("Profile not found"))
        })?
        .into();

    profile.verified = Set(true);

    // Delete used verification code
    let code_active: profile_verification_codes::ActiveModel = code.into();
    code_active.delete(&txn).await.map_err(|e| {
        tracing::error!("Failed to delete used verification code: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Update profile to set verified = true
    profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Fetch the updated profile to return
    let updated_profile = Profile::find_by_id(user_id)
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to fetch updated profile: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::error!("Profile disappeared after verification");
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    // Maintenance: Remove all expired codes in table (best-effort, don't fail if this errors)
    profile_verification_codes::Entity::delete_many()
        .filter(profile_verification_codes::Column::Expiration.lt(chrono::Utc::now()))
        .exec(&state.db)
        .await
        .map_err(|e| {
            tracing::warn!(
                "Failed to delete expired verification codes during cleanup: {}",
                e
            );
        })
        .ok();

    Ok(Json(updated_profile.into()))
}
