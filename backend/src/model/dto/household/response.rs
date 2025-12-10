use chrono::{DateTime, Utc};
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

use crate::{entity::households, model::dto::Coordinates};

use super::enums::HouseholdType;

#[derive(Debug, Serialize, ToSchema)]
pub struct HouseholdResponse {
    #[schema(value_type = String, format = "uuid", example = "550e8400-e29b-41d4-a716-446655440000")]
    pub id: Uuid,
    #[schema(example = "The Smith Family")]
    pub name: String,
    #[schema(example = "123 Main St, Springfield")]
    pub address_text: String,
    pub household_type: HouseholdType,
    pub coordinates: Coordinates,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: DateTime<Utc>,
    #[schema(value_type = String, format = "date-time")]
    pub updated_at: DateTime<Utc>,
}

impl From<households::Model> for HouseholdResponse {
    fn from(household: households::Model) -> Self {
        Self {
            id: household.id,
            name: household.name,
            address_text: household.address_text,
            household_type: household.household_type.into(),
            coordinates: Coordinates {
                lat: household.lat,
                lon: household.lon,
            },
            created_at: household.created_at.into(),
            updated_at: household.updated_at.into(),
        }
    }
}

#[derive(Debug, Serialize, ToSchema)]
pub struct InviteCodeResponse {
    #[schema(example = "123456")]
    pub code: String,
    #[schema(value_type = String, format = "uuid", example = "550e8400-e29b-41d4-a716-446655440000")]
    pub household_id: Uuid,
    #[schema(value_type = String, format = "date-time")]
    pub expires_at: DateTime<Utc>,
}
