use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(HouseholdInviteCodes::Table)
                    .col(
                        ColumnDef::new(HouseholdInviteCodes::Code)
                            .string_len(6)
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(HouseholdInviteCodes::Household)
                            .uuid()
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(HouseholdInviteCodes::Expiration)
                            .timestamp_with_time_zone()
                            .default(Expr::current_timestamp().add(Expr::cust("INTERVAL '1 HOUR'")))
                            .not_null(),
                    )
                    .primary_key(
                        Index::create()
                            .col(HouseholdInviteCodes::Code)
                            .col(HouseholdInviteCodes::Household),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .from_col(HouseholdInviteCodes::Household)
                            .to(Households::Table, Households::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await?;

        Ok(())
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .drop_table(Table::drop().table(HouseholdInviteCodes::Table).to_owned())
            .await?;

        Ok(())
    }
}

#[derive(DeriveIden)]
enum Households {
    Table,
    Id,
}

#[derive(DeriveIden)]
enum HouseholdInviteCodes {
    Table,
    Code,
    Household,
    Expiration,
}
