use axum::{Extension, Json, extract::State, response::Response};
use diesel::{
    ExpressionMethods, SelectableHelper,
    query_dsl::methods::{FilterDsl, SelectDsl},
};
use diesel_async::{AsyncConnection, RunQueryDsl};

use crate::{
    AppState,
    model::{
        self,
        diesel::households::{Household, NewHousehold},
    },
    schema,
    utils::firebase_auth::Claims,
};

#[utoipa::path(
    post,
    path = "/api/household",
    tag = "household",
    description = "Create a new household",
    responses(
        (status = 200, description = "Household created successfully", body = Household),
        (status = 401, description = "Unauthorized - Invalid or missing authentication token", body = model::api::error::UnauthorizedError),
        (status = 409, description = "User is already in a household", body = model::api::error::UserAlreadyInHouseholdError),
        (status = 500, description = "Internal server error", body = model::api::error::InternalServerError),
    ),
    request_body = model::api::household::CreateHouseholdRequest,
    security(
        ("bearerAuth" = [])
    )
)]
pub async fn create_household(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<model::api::household::CreateHouseholdRequest>,
) -> Result<Json<Household>, Response> {
    let household = NewHousehold { name: payload.name };

    let mut conn = state.pool.get().await.map_err(|e| {
        tracing::error!("Failed to get database connection: {}", e);
        model::api::error::ErrorResponse::internal_server_error()
    })?;

    let user_id = claims.user_id.clone();

    let household = conn
        .transaction::<Household, diesel::result::Error, _>(|conn| {
            Box::pin(async move {
                let old_household = schema::profiles::table
                    .filter(schema::profiles::id.eq(&user_id))
                    .select(schema::profiles::household_id)
                    .first::<Option<uuid::Uuid>>(conn)
                    .await?;

                if old_household.is_some() {
                    return Err(diesel::result::Error::RollbackTransaction);
                }

                let household = diesel::insert_into(schema::households::table)
                    .values(&household)
                    .returning(Household::as_returning())
                    .get_result::<Household>(conn)
                    .await?;

                diesel::update(schema::profiles::table)
                    .filter(schema::profiles::id.eq(&user_id))
                    .set(schema::profiles::household_id.eq(household.id))
                    .execute(conn)
                    .await?;

                Ok(household)
            })
        })
        .await
        .map_err(|e| match e {
            diesel::result::Error::RollbackTransaction => {
                tracing::warn!("User {} is already in a household", claims.user_id);
                model::api::error::ErrorResponse::user_already_in_household()
            }
            _ => {
                tracing::error!("Failed to create household: {}", e);
                model::api::error::ErrorResponse::internal_server_error()
            }
        })?;

    Ok(Json(household))
}
