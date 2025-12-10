pub use sea_orm_migration::prelude::*;

mod m20220101_000001_create_table;
mod m20251109_224906_create_households;
mod m20251110_200238_add_household_fields;
mod m20251110_215513_add_household_invite_code;
mod m20251110_222040_add_account_verification;
mod m20251110_225922_add_profile_verification_code;
mod m20251117_153027_remove_email_verification;
mod m20251210_220518_add_coords_to_household;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(m20220101_000001_create_table::Migration),
            Box::new(m20251109_224906_create_households::Migration),
            Box::new(m20251110_200238_add_household_fields::Migration),
            Box::new(m20251110_215513_add_household_invite_code::Migration),
            Box::new(m20251110_222040_add_account_verification::Migration),
            Box::new(m20251110_225922_add_profile_verification_code::Migration),
            Box::new(m20251117_153027_remove_email_verification::Migration),
            Box::new(m20251210_220518_add_coords_to_household::Migration),
        ]
    }
}
