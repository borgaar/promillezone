use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::CONFLICT;
const CODE: &str = "PROFILE_ALREADY_EXISTS";
const MESSAGE: &str = "User already has a profile";
pub const DESCRIPTION: &str = "A profile already exists for the authenticated user.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct ProfileAlreadyExists {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for ProfileAlreadyExists {
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
