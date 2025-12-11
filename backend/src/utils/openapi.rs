use utoipa::OpenApi;

use crate::handlers;

pub struct ScalarTags;
impl ScalarTags {
    pub const HOUSEHOLD: &str = "Household";
    pub const PROFILE: &str = "Profile";
}

#[derive(OpenApi)]
#[openapi(
    info(
        title = "Promillezone API",
        version = "0.0.1",
        description = "API for the Promillezone application",
        contact(
            name = "API Support",
        ),
    ),
    paths(
        handlers::profile::get_profile,
        handlers::profile::create_profile,
        handlers::household::create_household,
        handlers::household::create_invite_code,
        handlers::household::join_household,
        handlers::household::leave_household,
        handlers::household::get_household,
    ),
    modifiers(&SecurityAddon),
    tags(
        (name = ScalarTags::PROFILE, description = "Endpoints for managing the user's profile."),
        (name = ScalarTags::HOUSEHOLD, description = "Endpoints for managing the user's assigned household.")
    )
)]
pub struct ApiDoc;

struct SecurityAddon;

impl utoipa::Modify for SecurityAddon {
    fn modify(&self, openapi: &mut utoipa::openapi::OpenApi) {
        if let Some(components) = openapi.components.as_mut() {
            // Add security scheme
            components.add_security_scheme(
                "bearerAuth",
                utoipa::openapi::security::SecurityScheme::Http(
                    utoipa::openapi::security::HttpBuilder::new()
                        .scheme(utoipa::openapi::security::HttpAuthScheme::Bearer)
                        .bearer_format("JWT")
                        .description(Some("Firebase JWT token authentication"))
                        .build(),
                ),
            );
        }
    }
}
