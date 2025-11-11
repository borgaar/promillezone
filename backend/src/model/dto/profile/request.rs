use serde::Deserialize;
use utoipa::ToSchema;
use validator::Validate;

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct CreateProfileRequest {
    #[validate(length(min = 1, max = 32))]
    #[schema(example = "John", max_length = 32, min_length = 1)]
    pub first_name: String,
    #[validate(length(min = 1, max = 32))]
    #[schema(example = "Doe", max_length = 32, min_length = 1)]
    pub last_name: String,
}

#[derive(Debug, Deserialize, Validate, ToSchema)]
pub struct VerifyProfileRequest {
    #[validate(length(min = 6, max = 6))]
    #[schema(example = "123456", min_length = 6, max_length = 6)]
    pub code: String,
}

impl VerifyProfileRequest {
    pub fn is_valid_code(&self) -> bool {
        self.code.chars().all(|c| c.is_ascii_digit())
    }
}
