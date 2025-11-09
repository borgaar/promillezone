use crate::entity::{households, profiles};
use chrono::{DateTime, Utc};
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

/// Profile response with OpenAPI schema
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct ProfileResponse {
    pub id: String,
    pub email: String,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: DateTime<Utc>,
    pub first_name: String,
    pub last_name: String,
    #[schema(value_type = Option<String>)]
    pub household_id: Option<Uuid>,
}

impl From<profiles::Model> for ProfileResponse {
    fn from(model: profiles::Model) -> Self {
        Self {
            id: model.id,
            email: model.email,
            created_at: model.created_at.into(),
            first_name: model.first_name,
            last_name: model.last_name,
            household_id: model.household_id,
        }
    }
}

/// Household response with OpenAPI schema
#[derive(Debug, Clone, Serialize, ToSchema)]
pub struct HouseholdResponse {
    #[schema(value_type = String)]
    pub id: Uuid,
    pub name: String,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: DateTime<Utc>,
}

impl From<households::Model> for HouseholdResponse {
    fn from(model: households::Model) -> Self {
        Self {
            id: model.id,
            name: model.name,
            created_at: model.created_at.into(),
        }
    }
}
