use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::FORBIDDEN;
const CODE: &str = "EMAIL_NOT_VERIFIED";
const MESSAGE: &str = "Email address is not verified";
pub const DESCRIPTION: &str = "The user's email address has not been verified.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct EmailNotVerifiedError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for EmailNotVerifiedError {
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
