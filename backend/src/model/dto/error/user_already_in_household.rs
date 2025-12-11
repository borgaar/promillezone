use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::CONFLICT;
const CODE: &str = "USER_ALREADY_IN_HOUSEHOLD";
const MESSAGE: &str = "User is already in a household";
pub const DESCRIPTION: &str = "The user is already a member of a household, and must leave the current household before joining another.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct UserAlreadyInHouseholdError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for UserAlreadyInHouseholdError {
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
