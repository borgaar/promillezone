// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileResponse extends ProfileResponse {
  @override
  final DateTime createdAt;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String? householdId;
  @override
  final String id;
  @override
  final String lastName;
  @override
  final DateTime updatedAt;
  @override
  final bool verified;

  factory _$ProfileResponse([void Function(ProfileResponseBuilder)? updates]) =>
      (ProfileResponseBuilder()..update(updates))._build();

  _$ProfileResponse._(
      {required this.createdAt,
      required this.email,
      required this.firstName,
      this.householdId,
      required this.id,
      required this.lastName,
      required this.updatedAt,
      required this.verified})
      : super._();
  @override
  ProfileResponse rebuild(void Function(ProfileResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileResponseBuilder toBuilder() => ProfileResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileResponse &&
        createdAt == other.createdAt &&
        email == other.email &&
        firstName == other.firstName &&
        householdId == other.householdId &&
        id == other.id &&
        lastName == other.lastName &&
        updatedAt == other.updatedAt &&
        verified == other.verified;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, householdId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, verified.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileResponse')
          ..add('createdAt', createdAt)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('householdId', householdId)
          ..add('id', id)
          ..add('lastName', lastName)
          ..add('updatedAt', updatedAt)
          ..add('verified', verified))
        .toString();
  }
}

class ProfileResponseBuilder
    implements Builder<ProfileResponse, ProfileResponseBuilder> {
  _$ProfileResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _householdId;
  String? get householdId => _$this._householdId;
  set householdId(String? householdId) => _$this._householdId = householdId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _verified;
  bool? get verified => _$this._verified;
  set verified(bool? verified) => _$this._verified = verified;

  ProfileResponseBuilder() {
    ProfileResponse._defaults(this);
  }

  ProfileResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _email = $v.email;
      _firstName = $v.firstName;
      _householdId = $v.householdId;
      _id = $v.id;
      _lastName = $v.lastName;
      _updatedAt = $v.updatedAt;
      _verified = $v.verified;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileResponse other) {
    _$v = other as _$ProfileResponse;
  }

  @override
  void update(void Function(ProfileResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileResponse build() => _build();

  _$ProfileResponse _build() {
    final _$result = _$v ??
        _$ProfileResponse._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ProfileResponse', 'createdAt'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ProfileResponse', 'email'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ProfileResponse', 'firstName'),
          householdId: householdId,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ProfileResponse', 'id'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'ProfileResponse', 'lastName'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'ProfileResponse', 'updatedAt'),
          verified: BuiltValueNullFieldError.checkNotNull(
              verified, r'ProfileResponse', 'verified'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
