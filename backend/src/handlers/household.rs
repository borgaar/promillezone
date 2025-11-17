use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{
    ActiveModelTrait, ColumnTrait, EntityTrait, PaginatorTrait, QueryFilter, Set, TransactionTrait,
};
use validator::Validate;

use crate::{
    AppState,
    entity::prelude::*,
    entity::{household_invite_codes, households, profiles},
    middleware::firebase_auth::Claims,
    model::dto::{self, HouseholdResponse},
};

#[utoipa::path(
    post,
    path = "/api/household",
    tag = "household",
    description = "Create a new household with the authenticated user as the first member. Requires name, address, and household type (family, dorm, or other).",
    responses(
        (status = 200, description = "Household created successfully", body = HouseholdResponse),
        (status = 400, description = "Invalid request payload", body = dto::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 409, description = "User is already a member of a household", body = dto::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
    ),
    request_body = dto::CreateHouseholdRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::CreateHouseholdRequest>,
) -> Result<Json<HouseholdResponse>, Response> {
    // Validate request
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid create household request: {}", e);
        return Err(dto::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    let user_id = claims.user_id.clone();

    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Check if user already has a household
    let existing_profile = Profiles::find_by_id(&user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?;

    let profile = match existing_profile {
        Some(p) => {
            if p.household_id.is_some() {
                tracing::warn!("User {} is already in a household", user_id);
                return Err(dto::ErrorResponse::user_already_in_household());
            }
            p
        }
        None => {
            tracing::error!("Profile not found for user {}", user_id);
            return Err(dto::ErrorResponse::internal_server_error());
        }
    };

    // Create new household
    let new_household = households::ActiveModel {
        name: Set(payload.name),
        address_text: Set(payload.address_text),
        household_type: Set(payload.household_type.into()),
        ..Default::default()
    };

    let household = new_household.insert(&txn).await.map_err(|e| {
        tracing::error!("Failed to create household: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(household.id));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(household.into()))
}

#[utoipa::path(
    post,
    path = "/api/household/invite",
    tag = "household",
    description = "Generate a 6-digit numeric invite code for your household. The code expires in 1 hour and can only be used once. User must be part of a household.",
    responses(
        (status = 200, description = "Invite code created successfully", body = dto::InviteCodeResponse),
        (status = 400, description = "User is not a member of any household", body = dto::BadRequestError),
        (status = 400, description = "User is not a part of a household", body = dto::NoHouseholdError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_invite_code(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<dto::InviteCodeResponse>, Response> {
    let user_id = &claims.user_id;

    // Get user's profile
    let profile = Profiles::find_by_id(user_id)
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::ErrorResponse::not_found(Some("Profile not found"))
        })?;

    // Check if user is in a household
    let household_id = profile.household_id.ok_or_else(|| {
        tracing::warn!("User {} is not in a household", user_id);
        dto::ErrorResponse::bad_request(Some("You must be in a household to create invite codes"))
    })?;

    // Generate 6-digit code
    let code_as_int = rand::random_range(0..=999999);
    let code = format!("{:06}", code_as_int);

    tracing::info!(
        "Generated household invite code {} for household {}",
        code,
        household_id
    );

    // Create invite code (expiration set by database default)
    let invite_code = household_invite_codes::ActiveModel {
        code: Set(code.clone()),
        household: Set(household_id),
        ..Default::default()
    };

    let created_code = invite_code.insert(&state.db).await.map_err(|e| {
        tracing::error!("Failed to insert invite code: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(dto::InviteCodeResponse {
        code,
        household_id,
        expires_at: created_code.expiration.into(),
    }))
}

#[utoipa::path(
    post,
    path = "/api/household/join",
    tag = "household",
    description = "Join a household using a 6-digit numeric invite code. The code must be valid and not expired. Users can only be in one household at a time.",
    responses(
        (status = 200, description = "Successfully joined the household", body = HouseholdResponse),
        (status = 400, description = "Invalid code format, expired invite code, or invalid request payload", body = dto::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::NotFoundError),
        (status = 409, description = "User is already a member of a household", body = dto::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
    ),
    request_body = dto::JoinHouseholdRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn join_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::JoinHouseholdRequest>,
) -> Result<Json<HouseholdResponse>, Response> {
    // Validate request
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid join household request: {}", e);
        return Err(dto::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Validate code is numeric
    if !payload.is_valid_code() {
        tracing::warn!("Invite code contains non-numeric characters");
        return Err(dto::ErrorResponse::bad_request(Some(
            "Invite code must be numeric",
        )));
    }

    let user_id = &claims.user_id;

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Find valid invite code
    let invite = HouseholdInviteCodes::find()
        .filter(household_invite_codes::Column::Code.eq(payload.code.clone()))
        .filter(household_invite_codes::Column::Expiration.gt(chrono::Utc::now()))
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Invalid or expired invite code: {}", payload.code);
            dto::ErrorResponse::bad_request(Some("Invalid or expired invite code"))
        })?;

    // Get user's profile
    let profile = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::ErrorResponse::not_found(Some("Profile not found"))
        })?;

    // Check if user is already in a household
    if profile.household_id.is_some() {
        tracing::warn!("User {} is already in a household", user_id);
        return Err(dto::ErrorResponse::user_already_in_household());
    }

    // Get household details
    let household = Households::find_by_id(invite.household)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::error!("Household not found for invite code");
            dto::ErrorResponse::internal_server_error()
        })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(invite.household));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Delete used invite code
    let invite_active: household_invite_codes::ActiveModel = invite.into();
    invite_active.delete(&txn).await.map_err(|e| {
        tracing::error!("Failed to delete used invite code: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Maintenance: Clean up expired invite codes (best-effort)
    HouseholdInviteCodes::delete_many()
        .filter(household_invite_codes::Column::Expiration.lt(chrono::Utc::now()))
        .exec(&state.db)
        .await
        .map_err(|e| {
            tracing::warn!(
                "Failed to delete expired invite codes during cleanup: {}",
                e
            );
        })
        .ok();

    Ok(Json(household.into()))
}

#[utoipa::path(
    delete,
    path = "/api/household/leave",
    tag = "household",
    description = "Leave your current household. If you are the last member, the household will be automatically deleted along with any associated invite codes.",
    responses(
        (status = 200, description = "Successfully left the household"),
        (status = 400, description = "User is not a member of any household", body = dto::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn leave_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<(), Response> {
    // Get data from claims
    let user_id = &claims.user_id;
    let Some(household_id) = claims.household_id else {
        tracing::warn!(
            "User {} is not in a household, did the middleware fail?",
            user_id
        );
        return Err(dto::ErrorResponse::bad_request(Some(
            "You are not a member of any household",
        )));
    };

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Get the user's profile
    let mut profile: profiles::ActiveModel = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::ErrorResponse::not_found(Some("Profile not found"))
        })?
        .into();

    // Update profile to remove household_id
    profile.household_id = Set(None);

    profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    // Check if there are any remaining members in the household
    let remaining_members = Profiles::find()
        .filter(profiles::Column::HouseholdId.eq(household_id))
        .count(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to count household members: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?;

    // If no members left, delete the household (cascade will delete invite codes)
    if remaining_members == 0 {
        tracing::info!("Deleting empty household {}", household_id);

        Households::delete_by_id(household_id)
            .exec(&txn)
            .await
            .map_err(|e| {
                tracing::error!("Failed to delete household: {}", e);
                dto::ErrorResponse::internal_server_error()
            })?;
    } else {
        tracing::info!(
            "User {} left household {} ({} members remaining)",
            user_id,
            household_id,
            remaining_members
        );
    }

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    Ok(())
}
