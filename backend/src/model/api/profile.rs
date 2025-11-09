use serde::Deserialize;

#[derive(Deserialize, utoipa::ToSchema)]
pub struct CreateProfileRequest {
    pub first_name: String,
    pub last_name: String,
}
