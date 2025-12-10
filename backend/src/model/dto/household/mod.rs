pub mod enums;
pub mod request;
pub mod response;

pub use request::*;
pub use response::*;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Deserialize, Serialize, Debug, ToSchema)]
pub struct Coordinates {
    #[schema(example = 63.432200175276634)]
    pub lat: f32,
    #[schema(example = 10.394496855139566)]
    pub lon: f32,
}
