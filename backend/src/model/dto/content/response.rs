use serde::Serialize;
use serde_json::json;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema, Debug)]
pub struct ContentResponse {
    #[schema(example = json!([
        {
            "ImageContent": {
                "title": "Dagens katt",
                "url": "https://cataas.com/cat?width=300&height=300"
            }
        },
        {
            "TextContent": {
                "title": "Dagens vits",
                "text": "Why did the scarecrow win an award? Because he was outstanding in his field!",
                "font": "comic"
            }
        },
        {
            "TextContent": {
                "title": "Dagens visdomsord",
                "text": "The only true wisdom is in knowing you know nothing.",
                "font": "serif"
            }
        }
    ]))]
    pub content: Vec<ContentItem>,
    pub message: Option<Message>,
}

#[derive(Debug, ToSchema, Serialize)]
pub enum ContentItem {
    ImageContent {
        title: String,
        url: String,
    },
    TextContent {
        title: String,
        text: String,
        font: Option<Font>,
    },
}

#[derive(Debug, ToSchema, Serialize)]
#[schema(example = "serif")]
pub enum Font {
    #[serde(rename = "serif")]
    Serif,
    #[serde(rename = "sans-serif")]
    SansSerif,
    #[serde(rename = "comic")]
    Comic,
    #[serde(rename = "mono")]
    Mono,
}

#[derive(Serialize, ToSchema, Debug)]
pub struct Message {
    #[schema(example = "Husk å måke ute")]
    pub text: String,
    #[schema(example = "Borgar")]
    pub author: String,
}
