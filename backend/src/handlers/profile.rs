use axum::{Extension, Json, extract::State, response::Response};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;

use crate::model;
use crate::model::diesel::profile::Profile;
use crate::{AppState, utils::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = "profile",
    description = "Get the profile of the authenticated user",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = Profile),
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
) -> Result<Json<Profile>, Response> {
    use crate::schema::profiles::dsl::*;

    // Obtain a database connection
    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Query the database for the user's profile
    let profile = profiles
        .filter(id.eq(&claims.user_id))
        .select(Profile::as_select())
        .first::<Profile>(&mut conn)
        .await
        .optional()
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
        (status = 200, description = "User profile created successfully", body = Profile),
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
) -> Result<Json<Profile>, Response> {
    use crate::schema::profiles::dsl::*;

    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    // Check if profile already exists
    let exists = profiles
        .filter(id.eq(&claims.user_id))
        .select(diesel::dsl::count(id))
        .first::<i64>(&mut conn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    if exists > 0 {
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

    let new_profile = crate::model::diesel::profile::NewProfile {
        id: claims.user_id.clone(),
        email: claims.email.unwrap(),
        first_name: payload.first_name.clone(),
        last_name: payload.last_name.clone(),
    };

    let profile = diesel::insert_into(profiles)
        .values(&new_profile)
        .returning(Profile::as_returning())
        .get_result::<Profile>(&mut conn)
        .await
        .map_err(|e| {
            tracing::error!("Database insert failed: {}", e);
            model::api::error::ErrorResponse::internal_server_error()
        })?;

    Ok(Json(profile))
}
