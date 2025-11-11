// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unauthorized_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnauthorizedError extends UnauthorizedError {
  @override
  final String code;
  @override
  final String message;

  factory _$UnauthorizedError(
          [void Function(UnauthorizedErrorBuilder)? updates]) =>
      (UnauthorizedErrorBuilder()..update(updates))._build();

  _$UnauthorizedError._({required this.code, required this.message})
      : super._();
  @override
  UnauthorizedError rebuild(void Function(UnauthorizedErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnauthorizedErrorBuilder toBuilder() =>
      UnauthorizedErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnauthorizedError &&
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
    return (newBuiltValueToStringHelper(r'UnauthorizedError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class UnauthorizedErrorBuilder
    implements Builder<UnauthorizedError, UnauthorizedErrorBuilder> {
  _$UnauthorizedError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  UnauthorizedErrorBuilder() {
    UnauthorizedError._defaults(this);
  }

  UnauthorizedErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnauthorizedError other) {
    _$v = other as _$UnauthorizedError;
  }

  @override
  void update(void Function(UnauthorizedErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnauthorizedError build() => _build();

  _$UnauthorizedError _build() {
    final _$result = _$v ??
        _$UnauthorizedError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'UnauthorizedError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'UnauthorizedError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
