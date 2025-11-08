use axum::{Extension, Json, extract::State, http::StatusCode};
use bcrypt::{DEFAULT_COST, hash, verify};
use diesel::prelude::*;
use diesel_async::RunQueryDsl;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

use crate::{
    AppState,
    model::auth::{NewUser, User},
    schema::user,
    utils::jwt::{Claims, create_token},
};

#[derive(Debug, Validate, Deserialize)]
pub struct RegisterRequest {
    #[validate(email)]
    pub email: String,
    #[validate(length(min = 8))]
    pub password: String,
}

#[derive(Debug, Validate, Deserialize)]
pub struct LoginRequest {
    #[validate(email)]
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub token: String,
    pub user: UserResponse,
}

#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub email: String,
}

pub async fn register(
    State(state): State<AppState>,
    Json(payload): Json<RegisterRequest>,
) -> Result<Json<AuthResponse>, (StatusCode, Json<serde_json::Value>)> {
    payload.validate().map_err(|e| {
        eprintln!("Validation error: {}", e);
        (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({"error": "Invalid request"})),
        )
    })?;

    let mut conn = state.pool.get().await.map_err(|e| {
        eprintln!("Failed to get database connection: {}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Database connection failed"})),
        )
    })?;

    let existing_user = user::table
        .filter(user::email.eq(&payload.email))
        .select(User::as_select())
        .first::<User>(&mut conn)
        .await
        .optional()
        .map_err(|e| {
            eprintln!("Failed to check if user exists: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({"error": "Database query failed"})),
            )
        })?;

    if existing_user.is_some() {
        return Err((
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({"error": "Email already registered"})),
        ));
    }

    let password_hash = hash(&payload.password, DEFAULT_COST).map_err(|e| {
        eprintln!("Failed to hash password: {}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Password hashing failed"})),
        )
    })?;

    let new_user = NewUser {
        id: Uuid::new_v4(),
        email: payload.email.clone(),
        password_hash,
    };

    let user = diesel::insert_into(user::table)
        .values(&new_user)
        .returning(User::as_returning())
        .get_result::<User>(&mut conn)
        .await
        .map_err(|e| {
            // log error with information
            eprintln!("Failed to create user: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({"error": "User creation failed"})),
            )
        })?;

    // Generate JWT token
    let token = create_token(user.id, user.email.clone()).map_err(|e| {
        eprintln!("Failed to generate token: {}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Token generation failed"})),
        )
    })?;

    Ok(Json(AuthResponse {
        token,
        user: UserResponse { email: user.email },
    }))
}

pub async fn login(
    State(state): State<AppState>,
    Json(payload): Json<LoginRequest>,
) -> Result<Json<AuthResponse>, (StatusCode, Json<serde_json::Value>)> {
    payload.validate().map_err(|e| {
        eprintln!("Validation error: {}", e);
        (
            StatusCode::BAD_REQUEST,
            Json(serde_json::json!({"error": "Invalid request"})),
        )
    })?;

    let mut conn = state.pool.get().await.map_err(|_| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Database connection failed"})),
        )
    })?;

    let user = user::table
        .filter(user::email.eq(&payload.email))
        .select(User::as_select())
        .first::<User>(&mut conn)
        .await
        .map_err(|_| {
            (
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({"error": "Invalid credentials"})),
            )
        })?;

    let is_valid = verify(&payload.password, &user.password_hash).map_err(|_| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Password verification failed"})),
        )
    })?;

    if !is_valid {
        return Err((
            StatusCode::UNAUTHORIZED,
            Json(serde_json::json!({"error": "Invalid credentials"})),
        ));
    }

    let token = create_token(user.id, user.email.clone()).map_err(|_| {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Token generation failed"})),
        )
    })?;

    Ok(Json(AuthResponse {
        token,
        user: UserResponse { email: user.email },
    }))
}

pub async fn get_profile(Extension(claims): Extension<Claims>) -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "email": claims.email,
    }))
}
