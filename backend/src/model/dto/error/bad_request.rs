use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

static STATUS_CODE: StatusCode = StatusCode::BAD_REQUEST;
const CODE: &str = "BAD_REQUEST";
const MESSAGE: &str = "Bad request";
pub const DESCRIPTION: &str = "The request payload is invalid or malformed.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct BadRequestError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for BadRequestError {
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
