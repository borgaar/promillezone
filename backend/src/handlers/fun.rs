use axum::{Json, response::Response};

use crate::{
    lib::wisdom::get_random_wisdom,
    model::dto::{self, fun::response::WisdomResponse},
};

pub async fn get_wisdom() -> Result<Json<dto::fun::response::WisdomResponse>, Response> {
    Ok(Json(WisdomResponse {
        wisdom: get_random_wisdom(),
    }))
}
