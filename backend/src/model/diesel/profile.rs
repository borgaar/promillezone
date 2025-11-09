use diesel::prelude::*;
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

use crate::model;

#[derive(Debug, Serialize, Queryable, Selectable, Identifiable, Associations, ToSchema)]
#[diesel(table_name = crate::schema::profiles)]
#[diesel(belongs_to(model::diesel::households::Household, foreign_key = household_id))]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Profile {
    pub id: String,
    pub email: String,
    pub first_name: String,
    pub last_name: String,
    #[schema(value_type = String)]
    pub household_id: Option<Uuid>,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: chrono::DateTime<chrono::Utc>,
    #[serde(skip_serializing)]
    #[schema(value_type = String, format = "date-time")]
    #[allow(dead_code)]
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Insertable, ToSchema)]
#[diesel(table_name = crate::schema::profiles)]
pub struct NewProfile {
    pub id: String,
    pub email: String,
    pub first_name: String,
    pub last_name: String,
}
