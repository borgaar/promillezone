use sea_orm_migration::{prelude::*, schema::*};

use super::m20220101_000001_create_table::Profiles;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // Create households table
        manager
            .create_table(
                Table::create()
                    .table(Households::Table)
                    .if_not_exists()
                    .col(
                        uuid(Households::Id)
                            .primary_key()
                            .default(Expr::cust("gen_random_uuid()")),
                    )
                    .col(string(Households::Name).not_null())
                    .col(
                        timestamp_with_time_zone(Households::CreatedAt)
                            .not_null()
                            .default(Expr::cust("NOW()")),
                    )
                    .col(
                        timestamp_with_time_zone(Households::UpdatedAt)
                            .not_null()
                            .default(Expr::cust("NOW()")),
                    )
                    .to_owned(),
            )
            .await?;

        // Create trigger for households updated_at
        manager
            .get_connection()
            .execute_unprepared(
                r#"
                CREATE TRIGGER update_households_updated_at
                BEFORE UPDATE ON households
                FOR EACH ROW
                EXECUTE PROCEDURE update_updated_at_column();
                "#,
            )
            .await?;

        // Add household_id column to profiles table
        manager
            .alter_table(
                Table::alter()
                    .table(Profiles::Table)
                    .add_column(uuid_null(Profiles::HouseholdId))
                    .to_owned(),
            )
            .await?;

        // Add foreign key constraint
        manager
            .create_foreign_key(
                ForeignKey::create()
                    .name("fk_profiles_household_id")
                    .from(Profiles::Table, Profiles::HouseholdId)
                    .to(Households::Table, Households::Id)
                    .on_delete(ForeignKeyAction::NoAction)
                    .on_update(ForeignKeyAction::NoAction)
                    .to_owned(),
            )
            .await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // Remove foreign key
        manager
            .drop_foreign_key(
                ForeignKey::drop()
                    .name("fk_profiles_household_id")
                    .table(Profiles::Table)
                    .to_owned(),
            )
            .await?;

        // Remove household_id column from profiles
        manager
            .alter_table(
                Table::alter()
                    .table(Profiles::Table)
                    .drop_column(Profiles::HouseholdId)
                    .to_owned(),
            )
            .await?;

        // Drop households table
        manager
            .drop_table(Table::drop().table(Households::Table).to_owned())
            .await?;

        Ok(())
    }
}

#[derive(DeriveIden)]
pub enum Households {
    Table,
    Id,
    Name,
    CreatedAt,
    UpdatedAt,
}
