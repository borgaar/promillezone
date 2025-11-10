use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, EntityTrait, Set, TransactionTrait};

use crate::{
    AppState,
    entity::{households, profiles},
    model,
    model::api::response::HouseholdResponse,
    utils::firebase_auth::Claims,
};

#[utoipa::path(
    post,
    path = "/api/household",
    tag = "household",
    description = "Create a new household",
    responses(
        (status = 200, description = "Household created successfully", body = HouseholdResponse),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = model::api::error::UnauthorizedError),
        (status = 409, description = "User is already in a household", body = model::api::error::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = model::api::error::InternalServerError),
    ),
    request_body = model::api::household::CreateHouseholdRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<model::api::household::CreateHouseholdRequest>,
) -> Result<Json<HouseholdResponse>, Response> {
    let user_id = claims.user_id.clone();

    let txn = state.db.begin().await.map_err(|e| {
        tracing::error!("Failed to begin transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Check if user already has a household
    let existing_profile = profiles::Entity::find_by_id(&user_id)
        .one(&txn)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    let profile = match existing_profile {
        Some(p) => {
            if p.household_id.is_some() {
                tracing::warn!("User {} is already in a household", user_id);
                return Err(model::api::error::ErrorResponse::user_already_in_household());
            }
            p
        }
        None => {
            tracing::error!("Profile not found for user {}", user_id);
            return Err(model::api::error::ErrorResponse::internal_server_error());
        }
    };

    // Create new household
    let new_household = households::ActiveModel {
        name: Set(payload.name),
        ..Default::default()
    };

    let household = new_household.insert(&txn).await.map_err(|e| {
        tracing::error!("Failed to create household: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Update user's household_id
    let mut active_profile: profiles::ActiveModel = profile.into();
    active_profile.household_id = Set(Some(household.id));

    active_profile.update(&txn).await.map_err(|e| {
        tracing::error!("Failed to update profile: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Commit transaction
    txn.commit().await.map_err(|e| {
        tracing::error!("Failed to commit transaction: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(household.into()))
}
