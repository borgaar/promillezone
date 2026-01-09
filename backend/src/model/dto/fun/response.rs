use serde::Serialize;
use utoipa::ToSchema;

#[derive(Serialize, ToSchema, Debug)]
pub struct WisdomResponse {
    #[schema(example = "My dad got me a drone for Christmas 🔥🔥🔥")]
    pub wisdom: String,
}
