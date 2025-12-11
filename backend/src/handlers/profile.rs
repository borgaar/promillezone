use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, EntityTrait, Set};
use validator::Validate;

use crate::entity::prelude::*;
use crate::entity::profiles;
use crate::model::dto::{self};
use crate::utils::openapi::ApiTags;
use crate::{AppState, middleware::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = ApiTags::PROFILE,
    description = "Get the profile of the authenticated user. Returns the user's profile information if they are verified.",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = dto::profile::response::ProfileResponse),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 404, description = "Profile not found - User needs to create a profile first", body = dto::error::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
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
            dto::error::ErrorResponse::internal_server_error()
        })?;

    let Some(profile) = maybe_profile else {
        tracing::warn!("Profile not found for user {}", claims.user_id);
        return Err(dto::error::ErrorResponse::not_found(Some(
            "Profile not found. Have you remembered to create it first?",
        )));
    };

    Ok(Json(profile.into()))
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = ApiTags::PROFILE,
    description = "Create a profile for the authenticated user. Email must be present in JWT claims.",
    responses(
        (status = 200, description = "Profile created successfully", body = dto::profile::response::ProfileResponse),
        (status = 400, description = "Invalid request payload or email not provided in token claims", body = dto::error::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::error::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::error::ForbiddenError),
        (status = 409, description = "Profile already exists for this user", body = dto::error::ConflictError),
        (status = 500, description = "Internal server error", body = dto::error::InternalServerError),
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
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Check if profile already exists
    let exists = Profiles::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            dto::error::ErrorResponse::internal_server_error()
        })?;

    if exists.is_some() {
        return Err(dto::error::ErrorResponse::conflict(Some(
            "Profile already exists",
        )));
    }

    let Some(email) = claims.email.clone() else {
        tracing::error!(
            "Email not provided in token claims for user {}",
            claims.user_id
        );
        return Err(dto::error::ErrorResponse::bad_request(Some(
            "Email not provided in token claims",
        )));
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
        dto::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(profile.into()))
}
