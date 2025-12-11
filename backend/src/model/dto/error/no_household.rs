use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use serde::Serialize;
use utoipa::{ToSchema, schema};

use crate::model::dto::error::{ErrorResponse, ToHttpResponse};

const STATUS_CODE: StatusCode = StatusCode::CONFLICT;
const CODE: &str = "NO_HOUSEHOLD";
const MESSAGE: &str = "Profile does not belong to a household";
pub const DESCRIPTION: &str = "The user's profile is not associated with any household.";

#[derive(Debug, Serialize, ToSchema)]
#[schema(example = json!({
    "code": CODE,
    "message": MESSAGE
}))]
pub struct NoHouseholdError {
    pub code: String,
    pub message: String,
}

impl ToHttpResponse for NoHouseholdError {
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
