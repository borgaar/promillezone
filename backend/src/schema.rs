// @generated automatically by Diesel CLI.

diesel::table! {
    households (id) {
        id -> Uuid,
        name -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
    }
}

diesel::table! {
    profiles (id) {
        id -> Varchar,
        email -> Varchar,
        created_at -> Timestamptz,
        updated_at -> Timestamptz,
        #[max_length = 255]
        first_name -> Varchar,
        #[max_length = 255]
        last_name -> Varchar,
        household_id -> Nullable<Uuid>,
    }
}

diesel::joinable!(profiles -> households (household_id));

diesel::allow_tables_to_appear_in_same_query!(households, profiles,);
