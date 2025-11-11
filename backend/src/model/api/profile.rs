use serde::Deserialize;
use validator::Validate;

#[derive(Deserialize, Validate, utoipa::ToSchema)]
pub struct CreateProfileRequest {
    #[validate(length(min = 1, max = 32))]
    pub first_name: String,
    #[validate(length(min = 1, max = 32))]
    pub last_name: String,
}

#[derive(Deserialize, Validate, utoipa::ToSchema)]
pub struct VerifyProfileRequest {
    #[validate(length(min = 6, max = 6))]
    pub code: String,
}

impl VerifyProfileRequest {
    pub fn is_valid_code(&self) -> bool {
        self.code.chars().all(|c| c.is_ascii_digit())
    }
}
