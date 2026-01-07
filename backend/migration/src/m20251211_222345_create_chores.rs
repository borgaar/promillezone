use sea_orm_migration::prelude::*;

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Chores::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Chores::Id)
                            .uuid()
                            .not_null()
                            .primary_key()
                            .default(Expr::cust("gen_random_uuid()")),
                    )
                    .col(ColumnDef::new(Chores::Title).string().not_null())
                    .col(ColumnDef::new(Chores::Description).string())
                    .col(ColumnDef::new(Chores::HouseholdId).uuid().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .from_col(Chores::HouseholdId)
                            .to(Households::Table, Households::Id)
                            .on_update(ForeignKeyAction::Cascade)
                            .on_delete(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await?;

        manager
            .create_table(
                Table::create()
                    .table(ChoreTasks::Table)
                    .col(
                        ColumnDef::new(ChoreTasks::Id)
                            .uuid()
                            .primary_key()
                            .not_null()
                            .default(Expr::cust("gen_random_uuid()")),
                    )
                    .col(ColumnDef::new(ChoreTasks::Description).string().not_null())
                    .col(ColumnDef::new(ChoreTasks::ChoreId).uuid().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .from_col(ChoreTasks::ChoreId)
                            .to(Chores::Table, Chores::Id)
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
            .drop_table(Table::drop().table(ChoreTasks::Table).to_owned())
            .await?;

        manager
            .drop_table(Table::drop().table(Chores::Table).to_owned())
            .await?;

        Ok(())
    }
}

#[derive(DeriveIden)]
enum Chores {
    Table,
    Id,
    HouseholdId,
    Title,
    Description,
}

#[derive(DeriveIden)]
enum ChoreTasks {
    Table,
    Id,
    ChoreId,
    Description,
}

#[derive(DeriveIden)]
enum Households {
    Table,
    Id,
}
