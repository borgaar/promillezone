use sea_orm_migration::{
    prelude::{extension::postgres::Type, *},
    schema::string,
};

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_type(
                Type::create()
                    .as_enum(HouseholdType::HouseholdType)
                    .values([
                        HouseholdType::Family,
                        HouseholdType::Dorm,
                        HouseholdType::Other,
                    ])
                    .to_owned(),
            )
            .await?;

        manager
            .alter_table(
                Table::alter()
                    .table(Households::Table)
                    .add_column(string(Households::AddressText).not_null())
                    .add_column(
                        ColumnDef::new(Households::HouseholdType)
                            .custom(HouseholdType::HouseholdType)
                            .not_null(),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .alter_table(
                Table::alter()
                    .table(Households::Table)
                    .drop_column(Households::AddressText)
                    .drop_column(Households::HouseholdType)
                    .to_owned(),
            )
            .await?;

        manager
            .drop_type(Type::drop().name(HouseholdType::HouseholdType).to_owned())
            .await
    }
}

#[derive(DeriveIden)]
enum Households {
    Table,
    AddressText,
    HouseholdType,
}

#[derive(DeriveIden)]
enum HouseholdType {
    HouseholdType,
    Family,
    Dorm,
    Other,
}
