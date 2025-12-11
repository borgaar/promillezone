use serde::Deserialize;
use utoipa::ToSchema;
use validator::Validate;

use crate::model::dto::household::Coordinates;

use super::enums::HouseholdType;

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct CreateHouseholdRequest {
    #[validate(length(min = 1, max = 255))]
    #[schema(example = "The Smith Family", max_length = 255, min_length = 1)]
    pub name: String,
    #[validate(length(min = 1, max = 255))]
    #[schema(example = "123 Main St, Springfield", max_length = 255, min_length = 1)]
    pub address_text: String,
    #[schema(example = "family")]
    pub household_type: HouseholdType,
    pub coordinates: Coordinates,
}

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct JoinHouseholdRequest {
    #[validate(length(min = 6, max = 6))]
    #[schema(example = "123456", min_length = 6, max_length = 6)]
    pub code: String,
}

impl JoinHouseholdRequest {
    pub fn is_valid_code(&self) -> bool {
        self.code.chars().all(|c| c.is_ascii_digit())
    }
}
