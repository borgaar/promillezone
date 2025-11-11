use axum::{
    extract::{Request, State},
    middleware::Next,
    response::Response,
};
use sea_orm::{ColumnTrait, EntityTrait, QueryFilter};

use crate::{entity::profiles, middleware::firebase_auth::Claims, model::dto};

pub async fn inject_household(
    State(state): State<crate::AppState>,
    mut req: Request,
    next: Next,
) -> Response {
    let mut claims = req
        .extensions()
        .get::<Claims>()
        .cloned()
        .expect("Claims should be set by a previous middleware, probably the auth middleware");

    // Query the profile from the database
    let profile = match profiles::Entity::find()
        .filter(profiles::Column::Id.eq(&claims.user_id))
        .one(&state.db)
        .await
    {
        Ok(Some(profile)) => profile,
        Ok(None) => {
            tracing::warn!("Profile not found for user_id: {}", claims.user_id);
            return dto::ErrorResponse::not_found(Some("Profile not found"));
        }
        Err(err) => {
            tracing::error!(
                "Database error while fetching profile for user_id {}: {}",
                claims.user_id,
                err
            );
            return dto::ErrorResponse::internal_server_error();
        }
    };

    // Check if the profile has a household
    let household_id = match profile.household_id {
        Some(id) => id,
        None => {
            tracing::warn!(
                "Profile {} ({}) does not belong to a household",
                profile.id,
                profile.email
            );
            return dto::ErrorResponse::no_household();
        }
    };

    claims.household_id = Some(household_id);
    req.extensions_mut().insert(claims);

    next.run(req).await
}
