mod handlers;
mod model;
mod schema;
mod utils;

use axum::{
    Router, middleware as axum_middleware,
    routing::{get, post},
};
use diesel_async::{
    AsyncPgConnection,
    pooled_connection::{AsyncDieselConnectionManager, deadpool::Pool},
};
use std::{net::SocketAddr, sync::Arc};
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use utoipa::OpenApi;
use utoipa_scalar::{Scalar, Servable};

use crate::utils::firebase_auth::FirebaseAuth;

#[derive(OpenApi)]
#[openapi(
    paths(
        handlers::user::get_profile,
        handlers::user::create_profile,
    ),
    components(
        schemas(model::user::User, model::user::NewUser)
    ),
    tags(
        (name = "user", description = "User management endpoints")
    ),
    modifiers(&SecurityAddon)
)]
struct ApiDoc;

struct SecurityAddon;

impl utoipa::Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        if let Some(components) = openapi.components.as_mut() {
            components.add_security_scheme(
                "bearerAuth",
                utoipa::openapi::security::SecurityScheme::Http(
                    utoipa::openapi::security::Http::new(
                        utoipa::openapi::security::HttpAuthScheme::Bearer,
                    ),
                ),
            )
        }
    }
}

#[derive(Clone)]
pub struct AppState {
    pub pool: Pool<AsyncPgConnection>,
    pub firebase_auth: Arc<FirebaseAuth>,
}

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    // Initialize tracing
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "promillezone=info,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Starting Promillezone API server");

    let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
    let pool = Pool::builder(config)
        .build()
        .expect("Failed to create pool");

    tracing::info!("Database connection pool initialized");

    let firebase_auth = Arc::new(FirebaseAuth::new());
    tracing::info!("Firebase authentication configured");

    let state = AppState {
        pool,
        firebase_auth,
    };

    let app = Router::new()
        .route(
            "/api/auth/profile",
            get(handlers::user::get_profile).route_layer(axum_middleware::from_fn_with_state(
                state.clone(),
                utils::firebase_auth::auth_middleware,
            )),
        )
        .route(
            "/api/auth/profile",
            post(handlers::user::create_profile).route_layer(axum_middleware::from_fn_with_state(
                state.clone(),
                utils::firebase_auth::auth_middleware,
            )),
        )
        .layer(TraceLayer::new_for_http())
        .layer(CorsLayer::permissive())
        .merge(Scalar::with_url("/scalar", ApiDoc::openapi()))
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::info!("Server listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
