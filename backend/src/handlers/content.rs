use axum::{Json, response::Response};

use crate::{
    model::dto::{
        self,
        content::response::{ContentItem, ContentResponse, Font},
        error::{ToHttpResponse, email_not_verified, internal_server_error, unauthorized},
    },
    repository,
    utils::{openapi::ApiTags, uri_paths::UriPaths},
};

#[utoipa::path(
    get,
    path = UriPaths::CONTENT,
    tag = ApiTags::CONTENT,
    description = "Get the crucial daily information",
    responses(
        (status = StatusCode::OK, description = "Content retrieved successfully", body = dto::content::response::ContentResponse),
        (status = StatusCode::UNAUTHORIZED, description = unauthorized::DESCRIPTION, body = unauthorized::UnauthorizedError),
        (status = StatusCode::FORBIDDEN, description = email_not_verified::DESCRIPTION, body = email_not_verified::EmailNotVerifiedError),
        (status = StatusCode::INTERNAL_SERVER_ERROR, description = internal_server_error::DESCRIPTION, body = internal_server_error::InternalServerError),
    ),
)]
pub async fn get_content() -> Result<Json<dto::content::response::ContentResponse>, Response> {
    let cat_item = ContentItem::ImageContent {
        title: "Dagens katt".to_string(),
        url: "https://cataas.com/cat?width=300&height=300".to_string(),
    };

    let joke = reqwest::get("https://icanhazdadjoke.com")
        .await
        .map_err(|e| {
            tracing::error!("Failed to fetch joke: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?
        .text()
        .await
        .map_err(|e| {
            tracing::error!("Failed to fetch joke: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?;

    let joke_item = ContentItem::TextContent {
        title: "Dagens vits".to_string(),
        text: joke,
        font: Some(Font::Comic),
    };

    let wisdom_item = ContentItem::TextContent {
        title: "Dagens visdomsord".to_string(),
        text: repository::wisdom::get_random_wisdom().map_err(|e| {
            tracing::error!("Failed to fetch wisdom: {}", e);
            internal_server_error::InternalServerError::to_response()
        })?,
        font: Some(Font::Serif),
    };

    let content = vec![cat_item, joke_item, wisdom_item];

    Ok(Json(ContentResponse {
        content: content,
        message: None,
    }))
}
