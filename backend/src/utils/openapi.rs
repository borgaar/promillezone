use utoipa::OpenApi;

use crate::handlers;
use crate::model;

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Promillezone API",
        version = "0.1.0",
        description = "API for the Promillezone application",
        contact(
            name = "API Support",
        ),
    ),
    paths(
        handlers::user::get_profile,
        handlers::user::create_profile,
    ),
    components(
        schemas(
            model::user::User,
            model::error::ErrorResponse,
        )
    ),
    modifiers(&SecurityAddon),
    tags(
        (name = "user", description = "User management endpoints")
    )
)]
pub struct ApiDoc;

struct SecurityAddon;

impl utoipa::Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        if let Some(components) = openapi.components.as_mut() {
            components.add_security_scheme(
                "bearerAuth",
                utoipa::openapi::security::SecurityScheme::Http(
                    utoipa::openapi::security::HttpBuilder::new()
                        .scheme(utoipa::openapi::security::HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .description(Some("Firebase JWT token authentication"))
                        .build(),
                ),
            )
        }
    }
}
