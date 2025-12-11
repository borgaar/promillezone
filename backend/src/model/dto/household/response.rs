use chrono::{DateTime, Utc};
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

use crate::{
    entity::households,
    model::dto::household::{Coordinates, HouseholdMember},
};

use super::enums::HouseholdType;

#[derive(Debug, Serialize, ToSchema)]
pub struct GetHouseholdResponse {
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
    pub members: Vec<HouseholdMember>,
}

#[derive(Debug, Serialize, ToSchema)]
pub struct CreateHouseholdResponse {
    #[schema(value_type = String, format = "uuid", example = "550e8400-e29b-41d4-a716-446655440000")]
    pub id: Uuid,
    #[schema(example = "The Smith Family")]
    pub name: String,
    #[schema(example = "123 Main St, Springfield")]
    pub address_text: String,
    pub coordinated: Coordinates,
}

impl From<households::Model> for CreateHouseholdResponse {
    fn from(household: households::Model) -> Self {
        Self {
            id: household.id,
            name: household.name,
            address_text: household.address_text,
            coordinated: Coordinates {
                lat: household.lat,
                lon: household.lon,
            },
        }
    }
}

#[derive(Debug, Serialize, ToSchema)]
pub struct CreateInviteCodeResponse {
    #[schema(example = "123456")]
    pub code: String,
    #[schema(value_type = String, format = "uuid", example = "550e8400-e29b-41d4-a716-446655440000")]
    pub household_id: Uuid,
    #[schema(value_type = String, format = "date-time")]
    pub expires_at: DateTime<Utc>,
}
