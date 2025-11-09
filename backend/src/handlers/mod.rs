use axum::{http, response::Response};
use serde_json::json;

pub mod user;

pub fn internal_server_error_response() -> Response {
    axum::response::Response::builder()
        .status(axum::http::StatusCode::INTERNAL_SERVER_ERROR)
        .header(http::header::CONTENT_TYPE, "application/json")
        .body(axum::body::Body::from(
            json!({"error": "Internal server error"}).to_string(),
        ))
        .unwrap()
}
