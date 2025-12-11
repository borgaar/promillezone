use axum::{
    extract::{Request, State},
    middleware::Next,
    response::Response,
};
use sea_orm::{EntityTrait, QuerySelect};

use crate::{
    entity::profiles,
    middleware::firebase_auth::Claims,
    model::dto::error::{ToHttpResponse, internal_server_error, no_household, no_user_profile},
};

pub async fn inject_household(
    State(state): State<crate::AppState>,
    mut req: Request,
    next: Next,
) -> Result<Response, Response> {
    let mut claims = req
        .extensions()
        .get::<Claims>()
        .cloned()
        .expect("Claims should be set by a previous middleware, probably the auth middleware");

    // Query the profile from the database
    let Some(profile) = profiles::Entity::find_by_id(&claims.user_id)
        .select_only()
        .column(profiles::Column::HouseholdId)
        .one(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Failed to query profile for user {}: {}", claims.user_id, e);
            internal_server_error::InternalServerError::to_response()
        })?
    else {
        tracing::error!("Profile for user {} not found", claims.user_id);
        return Err(no_user_profile::NoUserProfileError::to_response());
    };

    let Some(household_id) = profile.household_id else {
        tracing::warn!(
            "User {} is not in a household. Middleware should have prevented this.",
            claims.user_id
        );
        return Err(no_household::NoHouseholdError::to_response());
    };

    claims.household_id = Some(household_id);
    req.extensions_mut().insert(claims);

    Ok(next.run(req).await)
}
