use serde::{Deserialize, Serialize};
use utoipa::ToSchema;

/// Household type for API requests and responses
#[derive(Debug, Clone, Deserialize, Serialize, ToSchema)]
#[serde(rename_all = "lowercase")]
pub enum HouseholdType {
    #[schema(rename = "family")]
    Family,
    #[schema(rename = "dorm")]
    Dorm,
    #[schema(rename = "other")]
    Other,
}

impl From<HouseholdType> for crate::entity::sea_orm_active_enums::HouseholdType {
    fn from(api_type: HouseholdType) -> Self {
        match api_type {
            HouseholdType::Family => crate::entity::sea_orm_active_enums::HouseholdType::Family,
            HouseholdType::Dorm => crate::entity::sea_orm_active_enums::HouseholdType::Dorm,
            HouseholdType::Other => crate::entity::sea_orm_active_enums::HouseholdType::Other,
        }
    }
}

impl From<crate::entity::sea_orm_active_enums::HouseholdType> for HouseholdType {
    fn from(db_type: crate::entity::sea_orm_active_enums::HouseholdType) -> Self {
        use crate::entity::sea_orm_active_enums::HouseholdType as DbType;

        match db_type {
            DbType::Family => HouseholdType::Family,
            DbType::Dorm => HouseholdType::Dorm,
            DbType::Other => HouseholdType::Other,
        }
    }
}
