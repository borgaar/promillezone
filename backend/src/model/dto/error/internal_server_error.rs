use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::INTERNAL_SERVER_ERROR;
const CODE: &str = "INTERNAL_SERVER_ERROR";
const MESSAGE: &str = "oh fuck. Internal server error";
pub const DESCRIPTION: &str = "oh fuck. An unexpected error occurred on the server.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct InternalServerError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for InternalServerError {
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
