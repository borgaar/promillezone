use chrono::NaiveDateTime;
use diesel::prelude::*;
use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

#[derive(Debug, Serialize, Deserialize, Queryable, Selectable, ToSchema)]
#[diesel(table_name = crate::schema::users)]
#[diesel(check_for_backend(diesel::pg::Pg))]
pub struct User {
    pub id: String,
    pub email: String,
    #[schema(value_type = String, format = DateTime)]
    pub created_at: NaiveDateTime,
    #[serde(skip_serializing)]
    #[schema(value_type = String, format = DateTime)]
    pub updated_at: NaiveDateTime,
}

#[derive(Debug, Insertable, Deserialize, ToSchema)]
#[diesel(table_name = crate::schema::users)]
pub struct NewUser {
    pub id: String,
    pub email: String,
}
