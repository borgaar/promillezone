use resend_rs::types::CreateEmailBaseOptions;

pub fn create_profile_verification_email(to: &str, code: &str) -> CreateEmailBaseOptions {
    let from = "support@promille.zone";

    CreateEmailBaseOptions::new(from, [to], "PromilleZone Profile Verification Code")
        .with_text(code)
}
