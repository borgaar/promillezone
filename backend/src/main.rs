mod entity;
mod handlers;
mod model;
mod utils;

use axum::{
    Router, middleware as axum_middleware,
    routing::{get, post},
};
use sea_orm::{Database, DatabaseConnection};
use std::{net::SocketAddr, sync::Arc};
use tower_http::{cors::CorsLayer, trace::TraceLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use utoipa::OpenApi;
use utoipa_scalar::{Scalar, Servable};

use crate::utils::{firebase_auth::FirebaseAuth, openapi::ApiDoc};

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
        .route("/api/auth/profile", get(handlers::profile::get_profile))
        .route("/api/auth/profile", post(handlers::profile::create_profile))
        .route(
            "/api/household",
            post(handlers::household::create_household),
        )
        .route_layer(axum_middleware::from_fn_with_state(
            state.clone(),
            utils::firebase_auth::auth_middleware,
        ));

    // Build OpenAPI spec
    let openapi = ApiDoc::openapi();

    let app = Router::new()
        .merge(protected)
        .layer(TraceLayer::new_for_http())
        .layer(CorsLayer::permissive())
        .merge(Scalar::with_url("/scalar", openapi))
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
