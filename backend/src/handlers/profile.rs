use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, EntityTrait, Set};
use validator::Validate;

use crate::entity::prelude::*;
use crate::entity::profiles;
use crate::model::dto::{self, ProfileResponse};
use crate::{AppState, middleware::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Get the profile of the authenticated user. Returns the user's profile information if they are verified.",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = ProfileResponse),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 404, description = "Profile not found - User needs to create a profile first", body = dto::NotFoundError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
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
    let maybe_profile = Profiles::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?;

    let Some(profile) = maybe_profile else {
        tracing::warn!("Profile not found for user {}", claims.user_id);
        return Err(dto::ErrorResponse::not_found(Some(
            "Profile not found. Have you remembered to create it first?",
        )));
    };

    Ok(Json(profile.into()))
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Create a profile for the authenticated user. Email must be present in JWT claims.",
    responses(
        (status = 200, description = "Profile created successfully", body = ProfileResponse),
        (status = 400, description = "Invalid request payload or email not provided in token claims", body = dto::BadRequestError),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = dto::UnauthorizedError),
        (status = 403, description = "Forbidden - You do not have permission to access this resource", body = dto::ForbiddenError),
        (status = 409, description = "Profile already exists for this user", body = dto::ConflictError),
        (status = 500, description = "Internal server error", body = dto::InternalServerError),
    ),
    request_body = dto::CreateProfileRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<dto::CreateProfileRequest>,
) -> Result<Json<ProfileResponse>, Response> {
    // Verify request validity
    if let Err(e) = payload.validate() {
        tracing::warn!("Invalid create profile request: {}", e);
        return Err(dto::ErrorResponse::bad_request(Some(
            "Invalid request payload",
        )));
    }

    // Check if profile already exists
    let exists = Profiles::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            dto::ErrorResponse::internal_server_error()
        })?;

    if exists.is_some() {
        return Err(dto::ErrorResponse::conflict(Some("Profile already exists")));
    }

    let Some(email) = claims.email.clone() else {
        tracing::error!(
            "Email not provided in token claims for user {}",
            claims.user_id
        );
        return Err(dto::ErrorResponse::bad_request(Some(
            "Email not provided in token claims",
        )));
    };

    let new_profile = profiles::ActiveModel {
        id: Set(claims.user_id.clone()),
        email: Set(email),
        first_name: Set(payload.first_name.clone()),
        last_name: Set(payload.last_name.clone()),
        ..Default::default()
    };

    let profile = new_profile.insert(&state.db).await.map_err(|e| {
        tracing::error!("Database insert failed: {}", e);
        dto::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(profile.into()))
}
