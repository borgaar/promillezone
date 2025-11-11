import 'package:equatable/equatable.dart';

// Domain Models

enum HouseholdType {
  family,
  dorm,
  other;
}

class Household extends Equatable {
  final String id;
  final String name;
  final String addressText;
  final HouseholdType householdType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Household({
    required this.id,
    required this.name,
    required this.addressText,
    required this.householdType,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        addressText,
        householdType,
        createdAt,
        updatedAt,
      ];
}

class InviteCode extends Equatable {
  final String code;
  final DateTime expiresAt;
  final String householdId;

  const InviteCode({
    required this.code,
    required this.expiresAt,
    required this.householdId,
  });

  @override
  List<Object?> get props => [code, expiresAt, householdId];
}

// Exception Types

abstract class HouseholdException implements Exception {
  final String code;
  final String message;

  const HouseholdException({required this.code, required this.message});

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class HouseholdBadRequestException extends HouseholdException {
  const HouseholdBadRequestException({
    required super.code,
    required super.message,
  });
}

class HouseholdUnauthorizedException extends HouseholdException {
  const HouseholdUnauthorizedException({
    required super.code,
    required super.message,
  });
}

class HouseholdNotFoundException extends HouseholdException {
  const HouseholdNotFoundException({
    required super.code,
    required super.message,
  });
}

class HouseholdConflictException extends HouseholdException {
  const HouseholdConflictException({
    required super.code,
    required super.message,
  });
}

class HouseholdInternalServerException extends HouseholdException {
  const HouseholdInternalServerException({
    required super.code,
    required super.message,
  });
}

class UserAlreadyInHouseholdException extends HouseholdException {
  const UserAlreadyInHouseholdException({
    required super.code,
    required super.message,
  });
}

class HouseholdUnknownException extends HouseholdException {
  const HouseholdUnknownException({
    required super.code,
    required super.message,
  });
}

// Repository Interface

abstract interface class HouseholdRepository {
  /// Creates a new household
  ///
  /// Throws:
  /// - [HouseholdBadRequestException] if request data is invalid
  /// - [HouseholdUnauthorizedException] if user is not authenticated
  /// - [UserAlreadyInHouseholdException] if user is already in a household
  /// - [HouseholdInternalServerException] if server error occurs
  Future<Household> createHousehold({
    required String name,
    required String address,
    required HouseholdType type,
  });

  /// Joins an existing household using an invite code
  ///
  /// Throws:
  /// - [HouseholdBadRequestException] if invite code is invalid
  /// - [HouseholdUnauthorizedException] if user is not authenticated
  /// - [HouseholdNotFoundException] if household doesn't exist
  /// - [UserAlreadyInHouseholdException] if user is already in a household
  /// - [HouseholdInternalServerException] if server error occurs
  Future<Household> joinHousehold({
    required String inviteCode,
  });

  /// Creates a new invite code for the user's household
  ///
  /// Throws:
  /// - [HouseholdUnauthorizedException] if user is not authenticated
  /// - [HouseholdNotFoundException] if user is not in a household
  /// - [HouseholdInternalServerException] if server error occurs
  Future<InviteCode> createInviteCode();

  /// Leaves the current household
  ///
  /// Throws:
  /// - [HouseholdUnauthorizedException] if user is not authenticated
  /// - [HouseholdNotFoundException] if user is not in a household
  /// - [HouseholdInternalServerException] if server error occurs
  Future<void> leaveHousehold();
}
