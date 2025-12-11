use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{
    ActiveModelTrait, ColumnTrait, ConnectionTrait, EntityTrait, PaginatorTrait, QueryFilter, Set,
    TransactionTrait,
};
use validator::Validate;

use crate::{
    AppState,
    entity::{
        household_invite_codes::{self},
        households,
        prelude::*,
        profiles,
    },
    middleware::firebase_auth::Claims,
    model::dto::{self},
    utils::{openapi::ApiTags, uri_paths::UriPaths},
};

#[utoipa::path(
    get,
    path = UriPaths::GET_HOUSEHOLD,
    tag = ApiTags::HOUSEHOLD,
    description = "Get the household details of the authenticated user. User must be a member of a household.",
    responses(
        (status = 200, description = "Household retrieved successfully", body = dto::household::response::GetHouseholdResponse),
        (status = 400, description = "User is not a member of any household", body = dto::error::NoHouseholdError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
    ),
)]
pub async fn get_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<dto::household::response::GetHouseholdResponse>, Response> {
    let household_id = claims.household_id.ok_or_else(|| {
        tracing::warn!(
            "User {} is not in a household. Middleware should have prevented this.",
            claims.user_id
        );
        dto::error::ErrorResponse::no_household()
    })?;

    let household = Households::find_by_id(
        household_id
    )
    .one(&state.db)
    .await
    .map_err(|e| {
        tracing::error!("Failed to query household: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?.ok_or_else(
        || {
            tracing::error!(
                "Household not found for user {}'s household_id {}. Household middleware should have prevented this.",
                claims.user_id,
                household_id
            );
            dto::error::ErrorResponse::no_household()
        }
    )?;

    let members = Profiles::find()
        .filter(profiles::Column::HouseholdId.eq(household_id))
        .all(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household members: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?;

    Ok(Json(dto::household::response::GetHouseholdResponse {
        id: household.id,
        name: household.name,
        address_text: household.address_text,
        household_type: household.household_type.into(),
        coordinates: dto::household::Coordinates {
            lat: household.lat,
            lon: household.lon,
        },
        created_at: household.created_at.into(),
        members: members.into_iter().map(|m| m.into()).collect(),
    }))
}

#[utoipa::path(
    post,
    path = UriPaths::CREATE_HOUSEHOLD,
    tag = ApiTags::HOUSEHOLD,
    description = "Create a new household with the authenticated user as the first member. Requires name, address, and household type (family, dorm, or other).",
    responses(
        (status = 200, description = "Household created successfully", body = dto::household::response::CreateHouseholdResponse),
        (status = 400, description = "Invalid request payload", body = dto::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 409, description = "User is already a member of a household", body = dto::error::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
    ),
    request_body = dto::household::request::CreateHouseholdRequest,
)]
pub async fn create_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::household::request::CreateHouseholdRequest>,
) -> Result<Json<dto::household::response::CreateHouseholdResponse>, Response> {
    // Validate request
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid create household request: {}", e);
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    let user_id = claims.user_id.clone();

    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Check if user already has a household
    let existing_profile = Profiles::find_by_id(&user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?;

    let profile = match existing_profile {
        Some(p) => {
            if p.household_id.is_some() {
                tracing::warn!("User {} is already in a household", user_id);
                return Err(dto::error::ErrorResponse::user_already_in_household());
            }
            p
        }
        None => {
            tracing::error!("Profile not found for user {}", user_id);
            return Err(dto::error::ErrorResponse::internal_server_error());
        }
    };

    // Create new household
    let new_household = households::ActiveModel {
        name: Set(payload.name),
        address_text: Set(payload.address_text),
        household_type: Set(payload.household_type.into()),
        created_at: Default::default(),
        lat: Set(payload.coordinates.lat),
        lon: Set(payload.coordinates.lat),
        id: Default::default(),
        updated_at: Default::default(),
    };

    let household = new_household.insert(&txn).await.map_err(|e| {
        tracing::error!("Failed to create household: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(household.id));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(household.into()))
}

#[utoipa::path(
    post,
    path = UriPaths::CREATE_HOUSEHOLD_INVITE,
    tag = ApiTags::HOUSEHOLD,
    description = "Generate a 6-digit numeric invite code for your household. The code expires in 1 hour and can only be used once. User must be part of a household.",
    responses(
        (status = 200, description = "Invite code created successfully", body = dto::household::response::CreateInviteCodeResponse),
        (status = 400, description = "User is not a member of any household", body = dto::error::BadRequestError),
        (status = 400, description = "User is not a part of a household", body = dto::error::NoHouseholdError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::error::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
    ),
)]
pub async fn create_invite_code(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<dto::household::response::CreateInviteCodeResponse>, Response> {
    let user_id = &claims.user_id;

    // Get user's profile
    let profile = Profiles::find_by_id(user_id)
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::error::ErrorResponse::not_found(Some("Profile not found"))
        })?;

    // Check if user is in a household
    let household_id = profile.household_id.ok_or_else(|| {
        tracing::warn!("User {} is not in a household", user_id);
        dto::error::ErrorResponse::bad_request(Some(
            "You must be in a household to create invite codes",
        ))
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
        expiration: Default::default(),
    };

    let created_code = invite_code.insert(&state.db).await.map_err(|e| {
        tracing::error!("Failed to insert invite code: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(dto::household::response::CreateInviteCodeResponse {
        code,
        household_id,
        expires_at: created_code.expiration.into(),
    }))
}

#[utoipa::path(
    post,
    path = UriPaths::JOIN_HOUSEHOLD,
    tag = ApiTags::HOUSEHOLD,
    description = "Join a household using a 6-digit numeric invite code. The code must be valid and not expired. Users can only be in one household at a time.",
    responses(
        (status = 200, description = "Successfully joined the household", body = dto::household::response::GetHouseholdResponse),
        (status = 400, description = "Invalid code format, expired invite code, or invalid request payload", body = dto::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::error::NotFoundError),
        (status = 409, description = "User is already a member of a household", body = dto::error::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
    ),
    request_body = dto::household::request::JoinHouseholdRequest,
)]
pub async fn join_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::household::request::JoinHouseholdRequest>,
) -> Result<Json<dto::household::response::GetHouseholdResponse>, Response> {
    // Validate request
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid join household request: {}", e);
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Validate code is numeric
    if !payload.is_valid_code() {
        tracing::warn!("Invite code contains non-numeric characters");
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "Invite code must be numeric",
        )));
    }

    let user_id = &claims.user_id;

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Find valid invite code
    let invite = HouseholdInviteCodes::find()
        .filter(household_invite_codes::Column::Code.eq(payload.code.clone()))
        .filter(household_invite_codes::Column::Expiration.gt(chrono::Utc::now()))
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Invalid or expired invite code: {}", payload.code);
            dto::error::ErrorResponse::bad_request(Some("Invalid or expired invite code"))
        })?;

    // Get user's profile
    let profile = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::error::ErrorResponse::not_found(Some("Profile not found"))
        })?;

    // Check if user is already in a household
    if profile.household_id.is_some() {
        tracing::error!("User {} is already in a household", user_id);
        return Err(dto::error::ErrorResponse::user_already_in_household());
    }

    // Get household details
    let household = Households::find_by_id(invite.household)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::error!("Household not found for invite code");
            dto::error::ErrorResponse::internal_server_error()
        })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(invite.household));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Delete used invite code
    let invite_active: household_invite_codes::ActiveModel = invite.into();
    invite_active.delete(&txn).await.map_err(|e| {
        tracing::error!("Failed to delete used invite code: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        dto::error::ErrorResponse::internal_server_error()
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

    let members = Profiles::find()
        .filter(profiles::Column::HouseholdId.eq(household.id))
        .all(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household members: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?;

    Ok(Json(dto::household::response::GetHouseholdResponse {
        id: household.id,
        name: household.name,
        address_text: household.address_text,
        household_type: household.household_type.into(),
        coordinates: dto::household::Coordinates {
            lat: household.lat,
            lon: household.lon,
        },
        created_at: household.created_at.into(),
        members: members.into_iter().map(|m| m.into()).collect(),
    }))
}

#[utoipa::path(
    delete,
    path = UriPaths::LEAVE_HOUSEHOLD,
    tag = ApiTags::HOUSEHOLD,
    description = "Leave your current household. If you are the last member, the household will be automatically deleted along with any associated data.",
    responses(
        (status = 200, description = "Successfully left the household"),
        (status = 400, description = "User is not a member of any household", body = dto::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 404, description = "Profile not found", body = dto::error::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
    ),
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
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "You are not a member of any household",
        )));
    };

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Get the user's profile
    let mut profile: profiles::ActiveModel = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            dto::error::ErrorResponse::not_found(Some("Profile not found"))
        })?
        .into();

    // Update profile to remove household_id
    profile.household_id = Set(None);

    profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        dto::error::ErrorResponse::internal_server_error()
    })?;

    // Atomically delete the household if no members remain
    let delete_result = txn
        .execute(sea_orm::Statement::from_sql_and_values(
            sea_orm::DatabaseBackend::Postgres,
            r#"
                DELETE FROM households
                WHERE id = $1
                AND NOT EXISTS (
                    SELECT 1 FROM profiles WHERE household_id = $1
                )
                "#,
            vec![household_id.into()],
        ))
        .await
        .map_err(|e| {
            tracing::error!("Failed to conditionally delete household: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?;

    if delete_result.rows_affected() > 0 {
        tracing::info!("Deleted empty household {}", household_id);
    } else {
        // Get the current remaining member count for logging
        let remaining_members = Profiles::find()
            .filter(profiles::Column::HouseholdId.eq(household_id))
            .count(&txn)
            .await
            .unwrap_or(0);
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
        dto::error::ErrorResponse::internal_server_error()
    })?;

    Ok(())
}
