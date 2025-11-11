import 'package:dio/dio.dart';
import 'package:promille_zone_api/promille_zone_api.dart' as api;
import 'repository.dart';

final class PromilleZoneHouseholdRepository implements HouseholdRepository {
  final api.PromilleZoneApi _api;

  PromilleZoneHouseholdRepository(this._api);

  api.HouseholdApi get _householdApi => _api.getHouseholdApi();

  @override
  Future<Household> createHousehold({
    required String name,
    required String address,
    required HouseholdType type,
  }) async {
    try {
      final request = api.CreateHouseholdRequestBuilder()
        ..name = name
        ..addressText = address
        ..householdType = _mapToApiHouseholdType(type);

      final response = await _householdApi.createHousehold(
        createHouseholdRequest: request.build(),
      );

      if (response.data == null) {
        throw const HouseholdUnknownException(
          code: 'no_data',
          message: 'No household data returned from server',
        );
      }

      return _mapToHousehold(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Household> joinHousehold({
    required String inviteCode,
  }) async {
    try {
      final request = api.JoinHouseholdRequestBuilder()..code = inviteCode;

      final response = await _householdApi.joinHousehold(
        joinHouseholdRequest: request.build(),
      );

      if (response.data == null) {
        throw const HouseholdUnknownException(
          code: 'no_data',
          message: 'No household data returned from server',
        );
      }

      return _mapToHousehold(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<InviteCode> createInviteCode() async {
    try {
      final response = await _householdApi.createInviteCode();

      if (response.data == null) {
        throw const HouseholdUnknownException(
          code: 'no_data',
          message: 'No invite code data returned from server',
        );
      }

      return _mapToInviteCode(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> leaveHousehold() async {
    try {
      await _householdApi.leaveHousehold();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Household _mapToHousehold(api.HouseholdResponse response) {
    return Household(
      id: response.id,
      name: response.name,
      addressText: response.addressText,
      householdType: _mapFromApiHouseholdType(response.householdType),
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }

  InviteCode _mapToInviteCode(api.InviteCodeResponse response) {
    return InviteCode(
      code: response.code,
      expiresAt: response.expiresAt,
      householdId: response.householdId,
    );
  }

  api.HouseholdType _mapToApiHouseholdType(HouseholdType type) {
    switch (type) {
      case HouseholdType.family:
        return api.HouseholdType.family;
      case HouseholdType.dorm:
        return api.HouseholdType.dorm;
      case HouseholdType.other:
        return api.HouseholdType.other;
    }
  }

  HouseholdType _mapFromApiHouseholdType(api.HouseholdType type) {
    return switch (type) {
      api.HouseholdType.family => HouseholdType.family,
      api.HouseholdType.dorm => HouseholdType.dorm,
      api.HouseholdType.other => HouseholdType.other,
      _ => HouseholdType.other, // Fallback for unknown types
    };
  }

  HouseholdException _handleError(DioException e) {
    final response = e.response;

    if (response == null) {
      return HouseholdUnknownException(
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
        return HouseholdBadRequestException(code: code, message: message);
      case 401:
        return HouseholdUnauthorizedException(code: code, message: message);
      case 404:
        return HouseholdNotFoundException(code: code, message: message);
      case 409:
        // Check if it's a UserAlreadyInHousehold error
        if (code == 'user_already_in_household' ||
            message.toLowerCase().contains('already in household')) {
          return UserAlreadyInHouseholdException(code: code, message: message);
        }
        return HouseholdConflictException(code: code, message: message);
      case 500:
        return HouseholdInternalServerException(code: code, message: message);
      default:
        return HouseholdUnknownException(code: code, message: message);
    }
  }
}
