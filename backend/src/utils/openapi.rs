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
        handlers::profile::get_profile,
        handlers::profile::create_profile,
        handlers::profile::verify_profile,
        handlers::household::create_household,
        handlers::household::create_invite_code,
        handlers::household::join_household,
        handlers::household::leave_household,
    ),
    components(
        schemas(
            model::api::response::ProfileResponse,
            model::api::response::HouseholdResponse,
            model::api::profile::CreateProfileRequest,
            model::api::profile::VerifyProfileRequest,
            model::api::household::CreateHouseholdRequest,
            model::api::household::CreateInviteCodeResponse,
            model::api::household::JoinHouseholdRequest,
            model::api::error::ErrorResponse,
            model::api::error::UnauthorizedError,
            model::api::error::NotFoundError,
            model::api::error::BadRequestError,
            model::api::error::ConflictError,
            model::api::error::UserAlreadyInHouseholdError,
            model::api::error::InternalServerError,
            model::api::error::ProfileNotVerifiedError,
        )
    ),
    modifiers(&SecurityAddon),
    tags(
        (name = "profile", description = "Profile management endpoints"),
        (name = "household", description = "Household management endpoints")
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
