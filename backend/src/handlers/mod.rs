use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde_json::json;

pub mod user;

pub fn error_response(status: StatusCode, message: &str) -> Response {
    (status, Json(json!({"error": message}))).into_response()
}

pub fn internal_server_error() -> Response {
    error_response(StatusCode::INTERNAL_SERVER_ERROR, "Internal server error")
}
