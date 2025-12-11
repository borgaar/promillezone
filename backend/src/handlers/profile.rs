use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, EntityTrait, Set};
use validator::Validate;

use crate::entity::prelude::*;
use crate::entity::profiles;
use crate::model::dto::error::*;
use crate::model::dto::{self};
use crate::utils::openapi::ApiTags;
use crate::{AppState, middleware::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = ApiTags::PROFILE,
    description = "Get the profile of the authenticated user. User must have a profile.",
    responses(
        (status = StatusCode::OK, description = "User profile retrieved successfully", body = dto::profile::response::ProfileResponse),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
    ),
)]
pub async fn get_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<dto::profile::response::ProfileResponse>, Response> {
    // Query the database for the user's profile
    let maybe_profile = Profiles::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?;

    let Some(profile) = maybe_profile else {
        tracing::error!("Profile not found for user {}", claims.user_id);
        return Err(no_user_profile::NoUserProfileError::to_response());
    };

    Ok(Json(profile.into()))
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = ApiTags::PROFILE,
    description = "Create a profile for the authenticated user. Email must be verified.",
    responses(
        (status = StatusCode::OK, description = "Profile created successfully", body = dto::profile::response::ProfileResponse),
        (status = StatusCode::BAD_REQUEST, description = bad_request::DESCRIPTION, body = bad_request::BadRequestError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::CONFLICT, description = profile_already_exists::DESCRIPTION, body = profile_already_exists::ProfileAlreadyExists),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
    ),
    request_body = dto::profile::request::CreateProfileRequest,
)]
pub async fn create_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::profile::request::CreateProfileRequest>,
) -> Result<Json<dto::profile::response::ProfileResponse>, Response> {
    // Verify request validity
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid create profile request: {}", e);
        return Err(bad_request::BadRequestError::to_response());
    }

    // Check if profile already exists
    let exists = Profiles::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?;

    if exists.is_some() {
        tracing::error!("Profile already exists for user {}", claims.user_id);
        return Err(profile_already_exists::ProfileAlreadyExists::to_response());
    }

    let Some(email) = claims.email.clone() else {
        tracing::error!(
            "Email not provided in token claims for user {}.",
            claims.user_id
        );
        return Err(internal_server_error::InternalServerError::to_response());
    };

    let new_profile = profiles::ActiveModel {
        id: Set(claims.user_id.clone()),
        email: Set(email),
        first_name: Set(payload.first_name),
        last_name: Set(payload.last_name),
        created_at: Default::default(),
        household_id: Default::default(),
        updated_at: Default::default(),
    };

    let profile = new_profile.insert(&state.db).await.map_err(|e| {
        tracing::error!("Database insert failed: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    Ok(Json(profile.into()))
}
