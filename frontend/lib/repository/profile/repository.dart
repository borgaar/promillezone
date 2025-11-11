import 'package:equatable/equatable.dart';

// Domain Models

class Profile extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? householdId;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.householdId,
    required this.verified,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        householdId,
        verified,
        createdAt,
        updatedAt,
      ];
}

// Exception Types

abstract class ProfileException implements Exception {
  final String code;
  final String message;

  const ProfileException({required this.code, required this.message});

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class ProfileBadRequestException extends ProfileException {
  const ProfileBadRequestException({
    required super.code,
    required super.message,
  });
}

class ProfileUnauthorizedException extends ProfileException {
  const ProfileUnauthorizedException({
    required super.code,
    required super.message,
  });
}

class ProfileNotFoundException extends ProfileException {
  const ProfileNotFoundException({
    required super.code,
    required super.message,
  });
}

class ProfileConflictException extends ProfileException {
  const ProfileConflictException({
    required super.code,
    required super.message,
  });
}

class ProfileInternalServerException extends ProfileException {
  const ProfileInternalServerException({
    required super.code,
    required super.message,
  });
}

class ProfileNotVerifiedException extends ProfileException {
  const ProfileNotVerifiedException({
    required super.code,
    required super.message,
  });
}

class ProfileUnknownException extends ProfileException {
  const ProfileUnknownException({
    required super.code,
    required super.message,
  });
}

// Repository Interface

abstract interface class ProfileRepository {
  /// Creates a new profile for the authenticated user
  /// Sends a verification email
  ///
  /// Throws:
  /// - [ProfileBadRequestException] if request data is invalid
  /// - [ProfileUnauthorizedException] if user is not authenticated
  /// - [ProfileConflictException] if profile already exists
  /// - [ProfileInternalServerException] if server error occurs
  Future<Profile> createProfile({
    required String firstName,
    required String lastName,
  });

  /// Gets the profile for the authenticated user
  ///
  /// Throws:
  /// - [ProfileUnauthorizedException] if user is not authenticated
  /// - [ProfileNotFoundException] if profile doesn't exist
  /// - [ProfileInternalServerException] if server error occurs
  Future<Profile> getProfile();

  /// Verifies the user's profile with a 6-digit verification code
  ///
  /// Throws:
  /// - [ProfileBadRequestException] if verification code is invalid
  /// - [ProfileUnauthorizedException] if user is not authenticated
  /// - [ProfileNotFoundException] if profile doesn't exist
  /// - [ProfileInternalServerException] if server error occurs
  Future<Profile> verifyProfile({
    required String code,
  });
}
