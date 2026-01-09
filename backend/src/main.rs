mod entity;
mod handlers;
mod lib;
mod middleware;
mod model;

use axum::{
    Router,
    routing::{delete, get, post},
};
use sea_orm::{Database, DatabaseConnection};
use std::{net::SocketAddr, sync::Arc};
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use utoipa::OpenApi;
use utoipa_scalar::{Scalar, Servable};

use crate::lib::openapi::ApiDoc;
use crate::{lib::uri_paths::UriPaths, middleware::firebase_auth::FirebaseAuth};

#[derive(Clone)]
pub struct AppState {
    pub db: DatabaseConnection,
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
    let db = Database::connect(&database_url)
        .await
        .expect("Failed to connect to database");

    tracing::info!("Database connection established");

    let firebase_auth = Arc::new(FirebaseAuth::new());
    tracing::info!("Firebase authentication configured");

    let state = AppState { db, firebase_auth };

    // Protected routes
    let protected = Router::new()
        .route(UriPaths::GET_PROFILE, get(handlers::profile::get_profile))
        .route(
            UriPaths::CREATE_PROFILE,
            post(handlers::profile::create_profile),
        )
        .route(
            UriPaths::CREATE_HOUSEHOLD,
            post(handlers::household::create_household),
        )
        .route(
            UriPaths::JOIN_HOUSEHOLD,
            post(handlers::household::join_household),
        )
        .route(UriPaths::WISDOM, get(handlers::fun::get_wisdom))
        .route_layer(axum::middleware::from_fn_with_state(
            state.clone(),
            middleware::firebase_auth::authenticate,
        ));

    // Routes that require both authentication and household membership
    let household_protected = Router::new()
        .route(
            UriPaths::CREATE_HOUSEHOLD_INVITE,
            post(handlers::household::create_invite_code),
        )
        .route(
            UriPaths::LEAVE_HOUSEHOLD,
            delete(handlers::household::leave_household),
        )
        .route(
            UriPaths::GET_HOUSEHOLD,
            get(handlers::household::get_household),
        )
        .route_layer(axum::middleware::from_fn_with_state(
            state.clone(),
            middleware::household::inject_household,
        ))
        .route_layer(axum::middleware::from_fn_with_state(
            state.clone(),
            middleware::firebase_auth::authenticate,
        ));

    // Build OpenAPI spec
    let openapi = ApiDoc::openapi();

    let opena_json = openapi
        .to_json()
        .expect("Failed to convert OpenAPI spec to JSON");

    let app = Router::new()
        .merge(protected)
        .merge(household_protected)
        .layer(TraceLayer::new_for_http())
        .layer(CorsLayer::permissive())
        .merge(Scalar::with_url(UriPaths::SCALAR, openapi.clone()))
        .merge(Router::new().route(UriPaths::OPENAPI_JSON, get(|| async move { opena_json })))
        .with_state(state);

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::info!("Server listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();

    // Serve with graceful shutdown
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap();

    tracing::info!("Server shutdown complete");
}

async fn shutdown_signal() {
    use tokio::signal;

    // Wait for the CTRL+C signal
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("Failed to install Ctrl+C handler");
    };

    // Wait for SIGTERM signal on Unix systems
    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("Failed to install SIGTERM handler")
            .recv()
            .await;
    };

    // On non-Unix systems, just await forever
    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {
            tracing::info!("Received Ctrl+C signal, shutting down gracefully");
        },
        _ = terminate => {
            tracing::info!("Received SIGTERM signal, shutting down gracefully");
        },
    }
}
