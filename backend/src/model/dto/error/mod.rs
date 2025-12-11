use axum::response::Response;
use serde::Serialize;
use utoipa::ToSchema;

pub mod bad_request;
pub mod email_not_verified;
pub mod internal_server_error;
pub mod invalid_household_invite_code;
pub mod no_household;
pub mod no_user_profile;
pub mod profile_already_exists;
pub mod unauthorized;
pub mod user_already_in_household;

pub trait ToHttpResponse {
    fn to_response() -> Response;
}

#[derive(Debug, Serialize, ToSchema)]
pub struct ErrorResponse {
    pub code: String,
    pub message: String,
}
