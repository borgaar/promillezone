use axum::{Extension, Json, extract::State, http::StatusCode, response::Response};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;

use crate::model::user::User;
use crate::{AppState, utils::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    tag = "user",
    description = "Get the profile of the authenticated user",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = User),
        (status = 404, description = "Profile not found", body = crate::model::error::ErrorResponse),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = crate::model::error::ErrorResponse),
        (status = 500, description = "Internal server error", body = crate::model::error::ErrorResponse),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn get_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<User>, Response> {
    use crate::schema::users::dsl::*;

    // Obtain a database connection
    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        super::internal_server_error()
    })?;

    // Query the database for the user's profile
    let profile = users
        .filter(id.eq(&claims.user_id))
        .first::<User>(&mut conn)
        .await
        .optional()
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            super::internal_server_error()
        })?;

    match profile {
        Some(user) => Ok(Json(user)),
        None => Err(super::error_response(
            StatusCode::NOT_FOUND,
            "Profile not found",
        )),
    }
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    tag = "user",
    description = "Create a profile for the authenticated user",
    responses(
        (status = 200, description = "User profile created successfully", body = User),
        (status = 409, description = "Profile already exists", body = crate::model::error::ErrorResponse),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = crate::model::error::ErrorResponse),
        (status = 500, description = "Internal server error", body = crate::model::error::ErrorResponse),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<User>, Response> {
    use crate::schema::users::dsl::*;

    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        super::internal_server_error()
    })?;

    // Check if profile already exists
    let exists = users
        .filter(id.eq(&claims.user_id))
        .select(diesel::dsl::count(id))
        .first::<i64>(&mut conn)
        .await
        .map_err(|e| {
            tracing::error!("Database query failed: {}", e);
            super::internal_server_error()
        })?;

    if exists > 0 {
        return Err(super::error_response(
            StatusCode::CONFLICT,
            "Profile already exists",
        ));
    }

    let new_user = crate::model::user::NewUser {
        id: claims.user_id.clone(),
        email: claims.email.clone(),
    };

    let user = diesel::insert_into(users)
        .values(&new_user)
        .get_result::<User>(&mut conn)
        .await
        .map_err(|e| {
            tracing::error!("Database insert failed: {}", e);
            super::internal_server_error()
        })?;

    Ok(Json(user))
}
