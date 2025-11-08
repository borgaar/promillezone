// @generated automatically by Diesel CLI.

diesel::table! {
    user (id) {
        id -> Uuid,
        email -> Varchar,
        password_hash -> Varchar,
        created_at -> Timestamp,
        updated_at -> Timestamp,
    }
}
