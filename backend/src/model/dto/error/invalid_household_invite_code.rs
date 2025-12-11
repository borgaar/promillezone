use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::FORBIDDEN;
const CODE: &str = "INVALID_HOUSEHOLD_INVITE_CODE";
const MESSAGE: &str = "Invalid or expired household invite code";
pub const DESCRIPTION: &str = "The provided household invite code is invalid or has expired.";

// What is used in the OpenAPI documentation
#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct InvalidHouseholdInviteCodeError {
    pub code: String,
    pub message: String,
}

// Implementation to convert the error into an HTTP response
impl ToHttpResponse for InvalidHouseholdInviteCodeError {
    fn to_response() -> Response {
        (
            STATUS_CODE,
            axum::Json(ErrorResponse {
                code: CODE.to_string(),
                message: MESSAGE.to_string(),
            }),
        )
            .into_response()
    }
}
