use serde::{Deserialize, Serialize};
use utoipa::ToSchema;
use validator::Validate;

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct CreateHouseholdRequest {
    pub name: String,
    #[validate(length(min = 3))]
    pub address_text: String,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct CreateInviteCodeResponse {
    pub code: String,
    #[schema(value_type = String, example = "2025-11-11T12:00:00Z")]
    pub expiration: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct JoinHouseholdRequest {
    #[validate(length(min = 6, max = 6))]
    pub code: String,
}

impl JoinHouseholdRequest {
    pub fn is_valid_code(&self) -> bool {
        self.code.chars().all(|c| c.is_ascii_digit())
    }
}
