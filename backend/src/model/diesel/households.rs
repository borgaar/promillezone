use diesel::{Insertable, Queryable, Selectable, prelude::Identifiable};
use serde::Serialize;
use utoipa::ToSchema;
use uuid::Uuid;

#[derive(Debug, Serialize, Queryable, Selectable, Identifiable, ToSchema)]
#[diesel(table_name = crate::schema::households)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct Household {
    #[schema(value_type = String)]
    pub id: Uuid,
    pub name: String,
    #[schema(value_type = String, format = "date-time")]
    pub created_at: chrono::DateTime<chrono::Utc>,
    #[schema(value_type = String, format = "date-time")]
    #[serde(skip_serializing)]
    #[allow(dead_code)]
    pub updated_at: chrono::DateTime<chrono::Utc>,
}

#[derive(Debug, Insertable, ToSchema)]
#[diesel(table_name = crate::schema::households)]
pub struct NewHousehold {
    pub name: String,
}
