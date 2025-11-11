import 'package:dio/dio.dart';
import 'package:promille_zone_api/promille_zone_api.dart';
import 'repository.dart';

final class PromilleZoneProfileRepository implements ProfileRepository {
  final PromilleZoneApi _api;

  PromilleZoneProfileRepository(this._api);

  ProfileApi get _profileApi => _api.getProfileApi();

  @override
  Future<Profile> createProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final request = CreateProfileRequestBuilder()
        ..firstName = firstName
        ..lastName = lastName;

      final response = await _profileApi.createProfile(
        createProfileRequest: request.build(),
      );

      if (response.data == null) {
        throw const ProfileUnknownException(
          code: 'no_data',
          message: 'No profile data returned from server',
        );
      }

      return _mapToProfile(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Profile> getProfile() async {
    try {
      final response = await _profileApi.getProfile();

      if (response.data == null) {
        throw const ProfileUnknownException(
          code: 'no_data',
          message: 'No profile data returned from server',
        );
      }

      return _mapToProfile(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Profile> verifyProfile({required String code}) async {
    try {
      final request = VerifyProfileRequestBuilder()..code = code;

      final response = await _profileApi.verifyProfile(
        verifyProfileRequest: request.build(),
      );

      if (response.data == null) {
        throw const ProfileUnknownException(
          code: 'no_data',
          message: 'No profile data returned from server',
        );
      }

      return _mapToProfile(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Profile _mapToProfile(ProfileResponse response) {
    return Profile(
      id: response.id,
      email: response.email,
      firstName: response.firstName,
      lastName: response.lastName,
      householdId: response.householdId,
      verified: response.verified,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }

  ProfileException _handleError(DioException e) {
    final response = e.response;

    if (response == null) {
      return ProfileUnknownException(
        code: 'network_error',
        message: e.message ?? 'Network error occurred',
      );
    }

    final data = response.data;

    // Try to extract error code and message from response
    String code = 'unknown';
    String message = 'An unknown error occurred';

    if (data is Map<String, dynamic>) {
      code = data['code']?.toString() ?? code;
      message = data['message']?.toString() ?? message;
    }

    switch (response.statusCode) {
      case 400:
        return ProfileBadRequestException(code: code, message: message);
      case 401:
        return ProfileUnauthorizedException(code: code, message: message);
      case 404:
        return ProfileNotFoundException(code: code, message: message);
      case 409:
        return ProfileConflictException(code: code, message: message);
      case 500:
        return ProfileInternalServerException(code: code, message: message);
      case 403:
        // Check if it's a ProfileNotVerified error
        if (code == 'profile_not_verified' ||
            message.toLowerCase().contains('not verified')) {
          return ProfileNotVerifiedException(code: code, message: message);
        }
        return ProfileUnauthorizedException(code: code, message: message);
      default:
        return ProfileUnknownException(code: code, message: message);
    }
  }
}
