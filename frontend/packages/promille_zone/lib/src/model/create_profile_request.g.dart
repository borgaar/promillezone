// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_profile_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateProfileRequest extends CreateProfileRequest {
  @override
  final String firstName;
  @override
  final String lastName;

  factory _$CreateProfileRequest(
          [void Function(CreateProfileRequestBuilder)? updates]) =>
      (CreateProfileRequestBuilder()..update(updates))._build();

  _$CreateProfileRequest._({required this.firstName, required this.lastName})
      : super._();
  @override
  CreateProfileRequest rebuild(
          void Function(CreateProfileRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateProfileRequestBuilder toBuilder() =>
      CreateProfileRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateProfileRequest &&
        firstName == other.firstName &&
        lastName == other.lastName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateProfileRequest')
          ..add('firstName', firstName)
          ..add('lastName', lastName))
        .toString();
  }
}

class CreateProfileRequestBuilder
    implements Builder<CreateProfileRequest, CreateProfileRequestBuilder> {
  _$CreateProfileRequest? _$v;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  CreateProfileRequestBuilder() {
    CreateProfileRequest._defaults(this);
  }

  CreateProfileRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstName = $v.firstName;
      _lastName = $v.lastName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateProfileRequest other) {
    _$v = other as _$CreateProfileRequest;
  }

  @override
  void update(void Function(CreateProfileRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateProfileRequest build() => _build();

  _$CreateProfileRequest _build() {
    final _$result = _$v ??
        _$CreateProfileRequest._(
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'CreateProfileRequest', 'firstName'),
          lastName: BuiltValueNullFieldError.checkNotNull(
              lastName, r'CreateProfileRequest', 'lastName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
