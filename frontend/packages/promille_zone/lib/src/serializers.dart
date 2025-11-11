//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:promille_zone_api/src/date_serializer.dart';
import 'package:promille_zone_api/src/model/date.dart';

import 'package:promille_zone_api/src/model/bad_request_error.dart';
import 'package:promille_zone_api/src/model/conflict_error.dart';
import 'package:promille_zone_api/src/model/create_household_request.dart';
import 'package:promille_zone_api/src/model/create_profile_request.dart';
import 'package:promille_zone_api/src/model/error_response.dart';
import 'package:promille_zone_api/src/model/household_response.dart';
import 'package:promille_zone_api/src/model/household_type.dart';
import 'package:promille_zone_api/src/model/internal_server_error.dart';
import 'package:promille_zone_api/src/model/invite_code_response.dart';
import 'package:promille_zone_api/src/model/join_household_request.dart';
import 'package:promille_zone_api/src/model/not_found_error.dart';
import 'package:promille_zone_api/src/model/profile_not_verified_error.dart';
import 'package:promille_zone_api/src/model/profile_response.dart';
import 'package:promille_zone_api/src/model/unauthorized_error.dart';
import 'package:promille_zone_api/src/model/user_already_in_household_error.dart';
import 'package:promille_zone_api/src/model/verify_profile_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  BadRequestError,
  ConflictError,
  CreateHouseholdRequest,
  CreateProfileRequest,
  ErrorResponse,
  HouseholdResponse,
  HouseholdType,
  InternalServerError,
  InviteCodeResponse,
  JoinHouseholdRequest,
  NotFoundError,
  ProfileNotVerifiedError,
  ProfileResponse,
  UnauthorizedError,
  UserAlreadyInHouseholdError,
  VerifyProfileRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
