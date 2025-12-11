use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::UNAUTHORIZED;
const CODE: &str = "UNAUTHORIZED";
const MESSAGE: &str = "Invalid or missing authentication token";
pub const DESCRIPTION: &str =
    "Request is not authenticated. The authentication token is missing or invalid.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct UnauthorizedError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for UnauthorizedError {
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
