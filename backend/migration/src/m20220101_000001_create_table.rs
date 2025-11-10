use sea_orm_migration::{prelude::*, schema::*};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        // Create update_updated_at_column function
        manager
            .get_connection()
            .execute_unprepared(
                r#"
                CREATE OR REPLACE FUNCTION update_updated_at_column()
                RETURNS TRIGGER AS $$
                BEGIN
                   NEW.updated_at = NOW();
                   RETURN NEW;
                END;
                $$ language 'plpgsql';
                "#,
            )
            .await?;

        // Create profiles table
        manager
            .create_table(
                Table::create()
                    .table(Profiles::Table)
                    .if_not_exists()
                    .col(string(Profiles::Id).primary_key())
                    .col(string(Profiles::Email).not_null().unique_key())
                    .col(
                        timestamp_with_time_zone(Profiles::CreatedAt)
                            .not_null()
                            .default(Expr::cust("NOW()")),
                    )
                    .col(
                        timestamp_with_time_zone(Profiles::UpdatedAt)
                            .not_null()
                            .default(Expr::cust("NOW()")),
                    )
                    .col(string(Profiles::FirstName).not_null())
                    .col(string(Profiles::LastName).not_null())
                    .to_owned(),
            )
            .await?;

        // Create trigger for profiles updated_at
        manager
            .get_connection()
            .execute_unprepared(
                r#"
                CREATE TRIGGER update_profiles_updated_at
                BEFORE UPDATE ON profiles
                FOR EACH ROW
                EXECUTE PROCEDURE update_updated_at_column();
                "#,
            )
            .await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(Profiles::Table).to_owned())
            .await?;

        manager
            .get_connection()
            .execute_unprepared("DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;")
            .await?;

        Ok(())
    }
}

#[derive(DeriveIden)]
pub enum Profiles {
    Table,
    Id,
    Email,
    CreatedAt,
    UpdatedAt,
    FirstName,
    LastName,
    HouseholdId,
}
