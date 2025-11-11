use axum::response::Response;
use axum::{http::StatusCode, response::IntoResponse};
use serde::Serialize;
#[allow(unused_imports)]
use serde_json::json;
use utoipa::ToSchema;

// Error code constants
pub const UNAUTHORIZED_CODE: &str = "UNAUTHORIZED";
pub const UNAUTHORIZED_MESSAGE: &str = "Unauthorized - Invalid or missing authentication token";

pub const NOT_FOUND_CODE: &str = "NOT_FOUND";
pub const NOT_FOUND_MESSAGE: &str = "Not found";

pub const BAD_REQUEST_CODE: &str = "BAD_REQUEST";
pub const BAD_REQUEST_MESSAGE: &str = "Bad request";

pub const CONFLICT_CODE: &str = "CONFLICT";
pub const CONFLICT_MESSAGE: &str = "<object> already exists";

pub const USER_ALREADY_IN_HOUSEHOLD_CODE: &str = "USER_ALREADY_IN_HOUSEHOLD";
pub const USER_ALREADY_IN_HOUSEHOLD_MESSAGE: &str = "User is already in a household";

pub const INTERNAL_SERVER_ERROR_CODE: &str = "INTERNAL_SERVER_ERROR";
pub const INTERNAL_SERVER_ERROR_MESSAGE: &str = "Internal server error";

pub const PROFILE_NOT_VERIFIED_ERROR_CODE: &str = "PROFILE_NOT_VERIFIED";
pub const PROFILE_NOT_VERIFIED_ERROR_MESSAGE: &str = "Profile is not verified";

pub const NO_HOUSEHOLD_CODE: &str = "NO_HOUSEHOLD";
pub const NO_HOUSEHOLD_MESSAGE: &str = "Profile does not belong to a household";

#[derive(Debug, Serialize, ToSchema)]
pub struct ErrorResponse {
    pub code: String,
    pub message: String,
}

// Example responses for documentation - these use the same constants as the runtime code
#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": UNAUTHORIZED_CODE,
    "message": UNAUTHORIZED_MESSAGE
}))]
pub struct UnauthorizedError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": NOT_FOUND_CODE,
    "message": "Profile not found"
}))]
pub struct NotFoundError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": BAD_REQUEST_CODE,
    "message": BAD_REQUEST_MESSAGE
}))]
pub struct BadRequestError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CONFLICT_CODE,
    "message": CONFLICT_MESSAGE
}))]
pub struct ConflictError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": INTERNAL_SERVER_ERROR_CODE,
    "message": INTERNAL_SERVER_ERROR_MESSAGE
}))]
pub struct InternalServerError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": USER_ALREADY_IN_HOUSEHOLD_CODE,
    "message": USER_ALREADY_IN_HOUSEHOLD_MESSAGE
}))]
pub struct UserAlreadyInHouseholdError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": PROFILE_NOT_VERIFIED_ERROR_CODE,
    "message": PROFILE_NOT_VERIFIED_ERROR_MESSAGE
}))]
pub struct ProfileNotVerifiedError {
    pub code: String,
    pub message: String,
}

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": NO_HOUSEHOLD_CODE,
    "message": NO_HOUSEHOLD_MESSAGE
}))]
pub struct NoHouseholdError {
    pub code: String,
    pub message: String,
}

// Implementations used by handlers to create error responses
impl ErrorResponse {
    pub fn internal_server_error() -> Response {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            axum::Json(ErrorResponse {
                code: INTERNAL_SERVER_ERROR_CODE.to_string(),
                message: INTERNAL_SERVER_ERROR_MESSAGE.to_string(),
            }),
        )
            .into_response()
    }

    pub fn unauthorized() -> Response {
        (
            StatusCode::UNAUTHORIZED,
            axum::Json(ErrorResponse {
                code: UNAUTHORIZED_CODE.to_string(),
                message: UNAUTHORIZED_MESSAGE.to_string(),
            }),
        )
            .into_response()
    }

    pub fn not_found(message: Option<&str>) -> Response {
        (
            StatusCode::NOT_FOUND,
            axum::Json(ErrorResponse {
                code: NOT_FOUND_CODE.to_string(),
                message: message.unwrap_or(NOT_FOUND_MESSAGE).to_string(),
            }),
        )
            .into_response()
    }

    pub fn user_already_in_household() -> Response {
        (
            StatusCode::CONFLICT,
            axum::Json(ErrorResponse {
                code: USER_ALREADY_IN_HOUSEHOLD_CODE.to_string(),
                message: USER_ALREADY_IN_HOUSEHOLD_MESSAGE.to_string(),
            }),
        )
            .into_response()
    }

    pub fn bad_request(message: Option<&str>) -> Response {
        (
            StatusCode::BAD_REQUEST,
            axum::Json(ErrorResponse {
                code: BAD_REQUEST_CODE.to_string(),
                message: message.unwrap_or(BAD_REQUEST_MESSAGE).to_string(),
            }),
        )
            .into_response()
    }

    pub fn conflict(message: Option<&str>) -> Response {
        (
            StatusCode::CONFLICT,
            axum::Json(ErrorResponse {
                code: CONFLICT_CODE.to_string(),
                message: message.unwrap_or(CONFLICT_MESSAGE).to_string(),
            }),
        )
            .into_response()
    }

    pub fn profile_not_verified() -> Response {
        (
            StatusCode::FORBIDDEN,
            axum::Json(ErrorResponse {
                code: PROFILE_NOT_VERIFIED_ERROR_CODE.to_string(),
                message: PROFILE_NOT_VERIFIED_ERROR_MESSAGE.to_string(),
            }),
        )
            .into_response()
    }

    pub fn no_household() -> Response {
        (
            StatusCode::BAD_REQUEST,
            axum::Json(ErrorResponse {
                code: NO_HOUSEHOLD_CODE.to_string(),
                message: NO_HOUSEHOLD_MESSAGE.to_string(),
            }),
        )
            .into_response()
    }
}
