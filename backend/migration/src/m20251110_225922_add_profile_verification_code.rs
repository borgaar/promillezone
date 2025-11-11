use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(ProfileVerificationCodes::Table)
                    .col(
                        ColumnDef::new(ProfileVerificationCodes::ProfileId)
                            .string()
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(ProfileVerificationCodes::Code)
                            .string_len(6)
                            .not_null(),
                    )
                    .col(
                        ColumnDef::new(ProfileVerificationCodes::Expiration)
                            .timestamp_with_time_zone()
                            .not_null()
                            .default(
                                Expr::current_timestamp().add(Expr::cust("INTERVAL '1 HOUR'")),
                            ),
                    )
                    .primary_key(
                        Index::create()
                            .col(ProfileVerificationCodes::ProfileId)
                            .col(ProfileVerificationCodes::Code),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .from_col(ProfileVerificationCodes::ProfileId)
                            .to(Profiles::Table, Profiles::Id)
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
            .drop_table(
                Table::drop()
                    .table(ProfileVerificationCodes::Table)
                    .to_owned(),
            )
            .await?;

        Ok(())
    }
}

#[derive(DeriveIden)]
enum Profiles {
    Table,
    Id,
}

#[derive(DeriveIden)]
enum ProfileVerificationCodes {
    Table,
    ProfileId,
    Code,
    Expiration,
}
