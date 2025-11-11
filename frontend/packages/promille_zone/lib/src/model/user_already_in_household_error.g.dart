// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_already_in_household_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserAlreadyInHouseholdError extends UserAlreadyInHouseholdError {
  @override
  final String code;
  @override
  final String message;

  factory _$UserAlreadyInHouseholdError(
          [void Function(UserAlreadyInHouseholdErrorBuilder)? updates]) =>
      (UserAlreadyInHouseholdErrorBuilder()..update(updates))._build();

  _$UserAlreadyInHouseholdError._({required this.code, required this.message})
      : super._();
  @override
  UserAlreadyInHouseholdError rebuild(
          void Function(UserAlreadyInHouseholdErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserAlreadyInHouseholdErrorBuilder toBuilder() =>
      UserAlreadyInHouseholdErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserAlreadyInHouseholdError &&
        code == other.code &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserAlreadyInHouseholdError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UserAlreadyInHouseholdErrorBuilder
    implements
        Builder<UserAlreadyInHouseholdError,
            UserAlreadyInHouseholdErrorBuilder> {
  _$UserAlreadyInHouseholdError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  UserAlreadyInHouseholdErrorBuilder() {
    UserAlreadyInHouseholdError._defaults(this);
  }

  UserAlreadyInHouseholdErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserAlreadyInHouseholdError other) {
    _$v = other as _$UserAlreadyInHouseholdError;
  }

  @override
  void update(void Function(UserAlreadyInHouseholdErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserAlreadyInHouseholdError build() => _build();

  _$UserAlreadyInHouseholdError _build() {
    final _$result = _$v ??
        _$UserAlreadyInHouseholdError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'UserAlreadyInHouseholdError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'UserAlreadyInHouseholdError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
