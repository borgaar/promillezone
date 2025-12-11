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
    model::dto::{self, error::*},
    utils::{openapi::ApiTags, uri_paths::UriPaths},
};

#[utoipa::path(
    get,
    path = UriPaths::GET_HOUSEHOLD,
    tag = ApiTags::HOUSEHOLD,
    description = "Get the household details of the authenticated user. User must be a member of a household.",
    responses(
        (status = StatusCode::OK, description = "Household retrieved successfully", body = dto::household::response::GetHouseholdResponse),
        (status = StatusCode::CONFLICT, description = no_household::DESCRIPTION, body = no_household::NoHouseholdError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
    ),
)]
pub async fn get_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<dto::household::response::GetHouseholdResponse>, Response> {
    let household_id = claims.household_id.ok_or_else(|| {
        tracing::warn!("Household is not in claims. Middleware should have prevented this.");
        internal_server_error::InternalServerError::to_response()
    })?;

    // Load household and its members in a single eager-load query
    let (household, members) = Households::find_by_id(household_id)
        .find_with_related(Profiles)
        .all(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household and members: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .first()
        .ok_or_else(|| {
            tracing::warn!("Household {} not found", household_id);
            internal_server_error::InternalServerError::to_response()
        })?
        .to_owned();

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
    description = "Create a new household with the authenticated user as the first member. The user must not already be part of a household (leave the current household first).",
    responses(
        (status = StatusCode::OK, description = "Household created successfully", body = dto::household::response::CreateHouseholdResponse),
        (status = StatusCode::BAD_REQUEST, description = bad_request::DESCRIPTION, body = bad_request::BadRequestError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::CONFLICT, description = user_already_in_household::DESCRIPTION, body = user_already_in_household::UserAlreadyInHouseholdError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
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
        return Err(bad_request::BadRequestError::to_response());
    }

    let user_id = claims.user_id.clone();

    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Check if user already has a household
    let existing_profile = Profiles::find_by_id(&user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?;

    let profile = match existing_profile {
        Some(p) => {
            if p.household_id.is_some() {
                tracing::warn!("User {} is already in a household", user_id);
                return Err(user_already_in_household::UserAlreadyInHouseholdError::to_response());
            }
            p
        }
        None => {
            tracing::error!("Profile not found for user {}", user_id);
            return Err(no_user_profile::NoUserProfileError::to_response());
        }
    };

    // Create new household
    let new_household = households::ActiveModel {
        name: Set(payload.name),
        address_text: Set(payload.address_text),
        household_type: Set(payload.household_type.into()),
        created_at: Default::default(),
        lat: Set(payload.coordinates.lat),
        lon: Set(payload.coordinates.lon),
        id: Default::default(),
        updated_at: Default::default(),
    };

    let household = new_household.insert(&txn).await.map_err(|e| {
        tracing::error!("Failed to create household: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(household.id));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    Ok(Json(household.into()))
}

#[utoipa::path(
    post,
    path = UriPaths::CREATE_HOUSEHOLD_INVITE,
    tag = ApiTags::HOUSEHOLD,
    description = "Generate a 6-digit numeric invite code for your household. The code expires in 1 hour and can only be used once. Inviting user must be part of a household.",
    responses(
        (status = StatusCode::OK, description = "Invite code created successfully", body = dto::household::response::CreateInviteCodeResponse),
        (status = StatusCode::CONFLICT, description = no_household::DESCRIPTION, body = no_household::NoHouseholdError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
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
            internal_server_error::InternalServerError::to_response()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            no_user_profile::NoUserProfileError::to_response()
        })?;

    // Check if user is in a household
    let household_id = profile.household_id.ok_or_else(|| {
        tracing::warn!("User {} is not in a household", user_id);
        no_household::NoHouseholdError::to_response()
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
        internal_server_error::InternalServerError::to_response()
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
    description = "Join a household using a 6-digit numeric invite code. The code must be valid and not expired. Users can only be in one household at a time. If already in a household, you must leave it first.",
    responses(
        (status = StatusCode::OK, description = "Successfully joined the household", body = dto::household::response::GetHouseholdResponse),
        (status = StatusCode::BAD_REQUEST, description = bad_request::DESCRIPTION, body = bad_request::BadRequestError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::FORBIDDEN, description = invalid_household_invite_code::DESCRIPTION, body = invalid_household_invite_code::InvalidHouseholdInviteCodeError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::CONFLICT, description = user_already_in_household::DESCRIPTION, body = user_already_in_household::UserAlreadyInHouseholdError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
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
        return Err(bad_request::BadRequestError::to_response());
    }

    // Validate code is numeric
    if !payload.is_valid_code() {
        tracing::warn!("Invite code contains non-numeric characters");
        return Err(bad_request::BadRequestError::to_response());
    }

    let user_id = &claims.user_id;

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Find valid invite code
    let invite = HouseholdInviteCodes::find()
        .filter(household_invite_codes::Column::Code.eq(payload.code.clone()))
        .filter(household_invite_codes::Column::Expiration.gt(chrono::Utc::now()))
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .ok_or_else(|| {
            tracing::warn!("Invalid or expired invite code: {}", payload.code);
            invalid_household_invite_code::InvalidHouseholdInviteCodeError::to_response()
        })?;

    // Get user's profile
    let profile = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            no_user_profile::NoUserProfileError::to_response()
        })?;

    // Check if user is already in a household
    if profile.household_id.is_some() {
        tracing::error!("User {} is already in a household", user_id);
        return Err(user_already_in_household::UserAlreadyInHouseholdError::to_response());
    }

    // Get household details
    let household = Households::find_by_id(invite.household)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .ok_or_else(|| {
            tracing::error!("Household not found for invite code");
            invalid_household_invite_code::InvalidHouseholdInviteCodeError::to_response()
        })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(invite.household));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Delete used invite code
    let invite_active: household_invite_codes::ActiveModel = invite.into();
    invite_active.delete(&txn).await.map_err(|e| {
        tracing::error!("Failed to delete used invite code: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        internal_server_error::InternalServerError::to_response()
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

    // Fetch the household together with members (single query)
    let household_with_members = Households::find()
        .filter(households::Column::Id.eq(household.id))
        .find_with_related(Profiles)
        .all(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query household members: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?;

    let members = match household_with_members.into_iter().next() {
        Some((_, m)) => m,
        None => Vec::new(),
    };

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
        (status = StatusCode::OK, description = "Successfully left the household"),
        (status = StatusCode::BAD_REQUEST, description = bad_request::DESCRIPTION, body = bad_request::BadRequestError),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::CONFLICT, description = no_user_profile::DESCRIPTION, body = no_user_profile::NoUserProfileError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
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
        return Err(no_household::NoHouseholdError::to_response());
    };

    // Start transaction
    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        internal_server_error::InternalServerError::to_response()
    })?;

    // Get the user's profile
    let mut profile: profiles::ActiveModel = Profiles::find_by_id(user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .ok_or_else(|| {
            tracing::warn!("Profile not found for user {}", user_id);
            no_user_profile::NoUserProfileError::to_response()
        })?
        .into();

    // Update profile to remove household_id
    profile.household_id = Set(None);

    profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        internal_server_error::InternalServerError::to_response()
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
            internal_server_error::InternalServerError::to_response()
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
        internal_server_error::InternalServerError::to_response()
    })?;

    Ok(())
}
