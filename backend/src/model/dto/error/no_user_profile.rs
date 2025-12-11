use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::CONFLICT;
const CODE: &str = "NO_USER_PROFILE";
const MESSAGE: &str = "User does not have a profile";
pub const DESCRIPTION: &str = "The authenticated user has not created a profile yet.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct NoUserProfileError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for NoUserProfileError {
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
