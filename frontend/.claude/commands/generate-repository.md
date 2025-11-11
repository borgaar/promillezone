---
description: Generate a repository with interface, implementation, domain models, and exceptions
---

Generate a repository for a domain API following the established pattern.

# Requirements

1. Create repository in `lib/repository/{domain}/`
2. Create `repository.dart` with:

   - Equatable domain models (NOT built_value - map from generated API models)
   - Custom exception types for each HTTP error code (400, 401, 404, 409, 500) plus domain-specific errors
   - Abstract interface class with named parameters for all methods
   - Comprehensive documentation for each method listing possible exceptions

3. Create `promille_zone.dart` implementation with:
   - Final class implementing the repository interface
   - Constructor accepting `PromilleZoneApi` dependency
   - Map generated built_value models to Equatable domain models
   - Catch `DioException` and throw typed exceptions based on:
     - HTTP status codes
     - Error response data (extract `code` and `message` fields)
     - Domain-specific error codes (e.g., profile_not_verified, user_already_in_household)
   - Handle null responses gracefully with UnknownException

# Pattern to Follow

Look at existing repositories:

- `lib/repository/profile/repository.dart` & `promille_zone.dart`
- `lib/repository/household/repository.dart` & `promille_zone.dart`

# Steps

1. Ask which domain/API to generate repository for
2. Read the generated API code in `packages/promille_zone/lib/src/api/{domain}_api.dart`
3. Read all model files referenced by the API (request/response models, enums)
4. Identify all possible error responses from API method signatures
5. Create domain models as Equatable classes (mirror generated models but simpler)
6. Create custom exception types (one per error type, all extending base exception)
7. Create abstract interface class with NAMED parameters
8. Create implementation class with mapping logic and error handling
9. Ensure all enum types are mapped between API and domain models

# Important Rules

- ALWAYS use named parameters: `method({required Type param})`
- Each exception type must include `code` and `message` fields from API
- Map ALL fields from API models to domain models
- Handle network errors (DioException with null response)
- Check for domain-specific error codes in error responses
- Use `final class` for implementations
- Use `abstract interface class` for interfaces
- All domain models extend Equatable with proper props implementation
