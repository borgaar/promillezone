use chrono::{DateTime, Utc};
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

use crate::entity::profiles;

#[derive(Debug, Serialize, ToSchema)]
pub struct ProfileResponse {
    #[schema(example = "firebase_user_id_123")]
    pub id: String,
    #[schema(example = "John")]
    pub first_name: String,
    #[schema(example = "Doe")]
    pub last_name: String,
    #[schema(example = "john.doe@example.com")]
    pub email: String,
    #[schema(value_type = Option<String>, format = "uuid", example = "550e8400-e29b-41d4-a716-446655440000")]
    pub household_id: Option<Uuid>,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: DateTime<Utc>,
    #[schema(value_type = String, format = "date-time")]
    pub updated_at: DateTime<Utc>,
}

impl From<profiles::Model> for ProfileResponse {
    fn from(profile: profiles::Model) -> Self {
        Self {
            id: profile.id,
            first_name: profile.first_name,
            last_name: profile.last_name,
            email: profile.email,
            household_id: profile.household_id,
            created_at: profile.created_at.into(),
            updated_at: profile.updated_at.into(),
        }
    }
}
