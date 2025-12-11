pub mod enums;
pub mod request;
pub mod response;

use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

use crate::entity::profiles;

#[derive(Deserialize, Serialize, Debug, ToSchema)]
pub struct Coordinates {
    #[schema(example = 63.432200175276634)]
    pub lat: f32,
    #[schema(example = 10.394496855139566)]
    pub lon: f32,
}

#[derive(Serialize, Debug, ToSchema)]
pub struct HouseholdMember {
    #[schema(example = "KYKWKfVs5suGFhQtIW9nyX4bxALv")]
    pub id: String,
    #[schema(example = "Brotherman")]
    pub first_name: String,
    #[schema(example = "Testern")]
    pub last_name: String,
}

impl From<profiles::Model> for HouseholdMember {
    fn from(model: profiles::Model) -> Self {
        HouseholdMember {
            id: model.id.into(),
            first_name: model.first_name,
            last_name: model.last_name,
        }
    }
}
