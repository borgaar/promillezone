use axum::response::Response;
use axum::{Extension, Json, extract::State, http};
use diesel::ExpressionMethods;
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use serde_json::json;

use crate::model;
use crate::{AppState, utils::firebase_auth::Claims};

#[utoipa::path(
    get,
    path = "/api/auth/profile",
    description = "Get the profile of the authenticated user",
    responses(
        (status = 200, description = "User profile retrieved successfully", body = model::user::User),
        (status = 404, description = "Profile not found"),
        (status = 500, description = "Internal server error"),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn get_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<model::user::User>, Response> {
    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        super::internal_server_error_response()
    })?;

    use crate::schema::users::dsl::*;

    let profile = users
        .filter(id.eq(&claims.user_id))
        .first::<model::user::User>(&mut conn)
        .await
        .optional()
        .map_err(|e| {
            tracing::error!("Database query failed while fetching user profile: {}", e);
            super::internal_server_error_response()
        })?;

    match profile {
        Some(user) => {
            tracing::debug!("User profile retrieved successfully");
            Ok(Json(user))
        }
        None => {
            tracing::info!("Profile not found for authenticated user");
            Err(axum::response::Response::builder()
                .status(http::StatusCode::NOT_FOUND)
                .header(http::header::CONTENT_TYPE, "application/json")
                .body(axum::body::Body::from(
                    json!({"error": "Profile not found"}).to_string(),
                ))
                .unwrap())
        }
    }
}

#[utoipa::path(
    post,
    path = "/api/auth/profile",
    description = "Create a profile for the authenticated user",
    request_body = model::user::NewUser,
    responses(
        (status = 200, description = "User profile created successfully", body = model::user::User),
        (status = 409, description = "Profile already exists"),
        (status = 500, description = "Internal server error"),
    ),
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_profile(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(_payload): Json<model::user::NewUser>,
) -> Result<Json<model::user::User>, Response> {
    use crate::schema::users::dsl::*;

    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        super::internal_server_error_response()
    })?;

    let existing_profile = users
        .filter(id.eq(&claims.user_id))
        .first::<model::user::User>(&mut conn)
        .await
        .optional()
        .map_err(|e| {
            tracing::error!(
                "Database query failed while checking existing profile: {}",
                e
            );
            super::internal_server_error_response()
        })?;

    if existing_profile.is_some() {
        tracing::info!("Profile creation attempted but profile already exists");
        return Err(axum::response::Response::builder()
            .status(http::StatusCode::CONFLICT)
            .header(http::header::CONTENT_TYPE, "application/json")
            .body(axum::body::Body::from(
                json!({"error": "Profile already exists"}).to_string(),
            ))
            .unwrap());
    }

    let new_user = model::user::NewUser {
        id: claims.user_id.clone(),
        email: claims.email.clone(),
    };

    let inserted_user = diesel::insert_into(users)
        .values(&new_user)
        .get_result::<model::user::User>(&mut conn)
        .await
        .map_err(|e| {
            tracing::error!("Database insert failed while creating profile: {}", e);
            super::internal_server_error_response()
        })?;

    tracing::info!("New user profile created successfully");
    Ok(Json(inserted_user))
}
