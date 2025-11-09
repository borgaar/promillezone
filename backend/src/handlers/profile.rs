use axum::{Extension, Json, extract::State, response::Response};
use sea_orm::{ActiveModelTrait, EntityTrait, Set};

use crate::entity::profiles::{self, Entity as Profile};
use crate::model;
use crate::{AppState, utils::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Get the profile of the authenticated user",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = profiles::Model),
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
) -> Result<Json<profiles::Model>, Response> {
    // Query the database for the user's profile
    let profile = Profile::find_by_id(claims.user_id.clone())
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    match profile {
        Some(user) => Ok(Json(user)),
        None => Err(model::api::error::ErrorResponse::not_found(Some(
            "Profile not found",
        ))),
    }
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Create a profile for the authenticated user",
    responses(
        (status = 200, description = "User profile created successfully", body = profiles::Model),
        (status = 400, description = "Email was not provided in token claims", body = model::api::error::BadRequestError),
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
) -> Result<Json<profiles::Model>, Response> {
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

    let profile = new_profile.insert(&state.db).await.map_err(|e| {
        tracing::error!("Database insert failed: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    Ok(Json(profile))
}
