pub struct UriPaths;

impl UriPaths {
    // PROFILE
    pub const CREATE_PROFILE: &str = "/api/auth/profile";
    pub const GET_PROFILE: &str = "/api/auth/profile";

    // HOUSEHOLD
    pub const GET_HOUSEHOLD: &str = "/api/household";
    pub const CREATE_HOUSEHOLD: &str = "/api/household";
    pub const CREATE_HOUSEHOLD_INVITE: &str = "/api/household/invite";
    pub const JOIN_HOUSEHOLD: &str = "/api/household/join";
    pub const LEAVE_HOUSEHOLD: &str = "/api/household";

    // API Docs
    pub const SCALAR: &str = "/scalar";
    pub const OPENAPI_JSON: &str = "/openapi.json";

    // FUN
    pub const WISDOM: &str = "/wisdom";
}
