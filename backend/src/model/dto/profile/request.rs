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
