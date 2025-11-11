use axum::{
    extract::{Request, State},
    http::{header},
    middleware::Next,
    response::{Response},
};
use jsonwebtoken::{DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, time::SystemTime};
use tokio::sync::RwLock;

use crate::model::dto;

pub struct FirebaseAuth {
    firebase_key_url: String,
    project_id: String,
    cache: RwLock<KeyCache>,
}

struct KeyCache {
    expiry: SystemTime,
    keys: Option<HashMap<String, DecodingKey>>,
}

#[derive(Deserialize)]
struct FirebaseKeysResponse {
    #[serde(flatten)]
    keys: HashMap<String, String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    // Standard JWT claims
    pub iss: String,           // Issuer
    pub aud: String,           // Audience (project ID)
    pub sub: String,           // Subject (user ID)
    pub iat: i64,              // Issued at
    pub exp: i64,              // Expiration
    pub auth_time: i64,        // Authentication time
    
    // Firebase-specific claims
    pub user_id: String,       // Same as sub
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email_verified: Option<bool>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub phone_number: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub picture: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub firebase: Option<FirebaseInfo>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct FirebaseInfo {
    pub identities: HashMap<String, Vec<String>>,
    pub sign_in_provider: String,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sign_in_second_factor: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub second_factor_identifier: Option<String>,
    
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tenant: Option<String>,
}

impl FirebaseAuth {
    pub fn new() -> Self {
        tracing::debug!("Initializing FirebaseAuth");
        
        FirebaseAuth {
            firebase_key_url: 
                "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
                .to_string(),
            project_id: "promillezone-v2".to_string(),
            cache: RwLock::new(KeyCache {
                expiry: SystemTime::UNIX_EPOCH,
                keys: None,
            }),
        }
    }

    pub async fn get_keys(&self) -> Result<HashMap<String, DecodingKey>, String> {
        // Check if cache is valid first
        {
            let cache = self.cache.read().await;
            if let Some(ref keys) = cache.keys {
                if SystemTime::now() < cache.expiry {
                    tracing::debug!("Using cached Firebase keys");
                    return Ok(keys.clone());
                }
            }
        }

        tracing::info!("Fetching fresh Firebase public keys");

        // Acquire write lock to update cache
        let mut cache = self.cache.write().await;

        // Double-check in case another task already updated it
        if let Some(ref keys) = cache.keys {
            if SystemTime::now() < cache.expiry {
                tracing::debug!("Keys refreshed by another task, using cached version");
                return Ok(keys.clone());
            }
        }

        // Fetch keys from Firebase
        let resp = reqwest::get(&self.firebase_key_url)
            .await
            .map_err(|e| {
                tracing::error!("Failed to fetch Firebase keys from Google: {}", e);
                format!("Failed to fetch Firebase keys: {}", e)
            })?;

        // Determine cache duration from response headers   
        let cache_duration = resp
            .headers()
            .get("cache-control")
            .and_then(|h| h.to_str().ok())
            .and_then(|s| {
                s.split(',')
                    .find(|part| part.trim().starts_with("max-age="))
                    .and_then(|part| part.trim().strip_prefix("max-age="))
                    .and_then(|age| age.parse::<u64>().ok())
            })
            .unwrap_or(3600);

        tracing::debug!("Firebase keys cache duration: {}s", cache_duration);

        // Parse the response JSON
        let keys_response: FirebaseKeysResponse = resp
            .json()
            .await
            .map_err(|e| {
                tracing::error!("Failed to parse Firebase keys response: {}", e);
                format!("Failed to parse Firebase keys response: {}", e)
            })?;

        // Convert to DecodingKey map
        let mut decoding_keys = HashMap::new();
        for (kid, key_str) in keys_response.keys {
            let decoding_key = DecodingKey::from_rsa_pem(key_str.as_bytes())
                .map_err(|e| {
                    tracing::error!("Failed to parse RSA key: {}", e);
                    format!("Failed to parse RSA key for kid {}: {}", kid, e)
                })?;
            decoding_keys.insert(kid, decoding_key);
        }

        tracing::info!("Successfully fetched and cached {} Firebase public keys", decoding_keys.len());

        // Update cache
        cache.keys = Some(decoding_keys.clone());
        cache.expiry = SystemTime::now() + std::time::Duration::from_secs(cache_duration);

        Ok(decoding_keys)
    }
}

impl Default for FirebaseAuth {
    fn default() -> Self {
        Self::new()
    }
}

pub async fn auth_middleware(
    State(state): State<crate::AppState>,
    mut req: Request,
    next: Next,
) -> Response {
    // Extract JWT from header
    let Some(token) = req
        .headers()
        .get(header::AUTHORIZATION)
        .and_then(|h| h.to_str().ok())
        .and_then(|h| h.strip_prefix("Bearer "))
    else {
        return dto::ErrorResponse::unauthorized();
    };

    // Get Firebase signing keys
    let Ok(keys) = state.firebase_auth.get_keys().await else {
        tracing::error!("Failed to get Firebase Auth signing keys");
        return dto::ErrorResponse::internal_server_error();
    };

    // Decode token header and get key ID used for signing
    let Ok(header) = jsonwebtoken::decode_header(token) else {
        tracing::error!("Failed to decode JWT header");
        return dto::ErrorResponse::unauthorized();
    };
    
    let Some(kid) = header.kid else {
        tracing::error!("JWT header missing key ID (kid)");
        return dto::ErrorResponse::unauthorized();
    };
    
    let Some(decoding_key) = keys.get(&kid) else {
        tracing::error!("No matching Firebase public key found for kid: {}", kid);
        return dto::ErrorResponse::unauthorized();
    };

    // Validate token claims
    let mut validation = Validation::new(Algorithm::RS256);
    validation.set_audience(&[&state.firebase_auth.project_id]);
    validation.set_issuer(&[format!("https://securetoken.google.com/{}", state.firebase_auth.project_id)]);
    validation.validate_exp = true;
    validation.validate_nbf = false;
    validation.leeway = 60;

    let token_data = match jsonwebtoken::decode::<Claims>(token, decoding_key, &validation) {
        Ok(data) => data,
        Err(e) => {
            tracing::error!("Failed to validate JWT: {}", e);
            return dto::ErrorResponse::unauthorized();
        }
    };

    if token_data.claims.sub.is_empty() {
        tracing::error!("JWT subject (sub) claim is empty");
        return dto::ErrorResponse::unauthorized();
    }

    // Insert claims into request extensions for downstream handlers
    req.extensions_mut().insert(token_data.claims);
    next.run(req).await
}

