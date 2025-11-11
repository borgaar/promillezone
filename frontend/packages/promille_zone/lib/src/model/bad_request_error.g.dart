// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bad_request_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BadRequestError extends BadRequestError {
  @override
  final String code;
  @override
  final String message;

  factory _$BadRequestError([void Function(BadRequestErrorBuilder)? updates]) =>
      (BadRequestErrorBuilder()..update(updates))._build();

  _$BadRequestError._({required this.code, required this.message}) : super._();
  @override
  BadRequestError rebuild(void Function(BadRequestErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BadRequestErrorBuilder toBuilder() => BadRequestErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BadRequestError &&
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
    return (newBuiltValueToStringHelper(r'BadRequestError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class BadRequestErrorBuilder
    implements Builder<BadRequestError, BadRequestErrorBuilder> {
  _$BadRequestError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  BadRequestErrorBuilder() {
    BadRequestError._defaults(this);
  }

  BadRequestErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BadRequestError other) {
    _$v = other as _$BadRequestError;
  }

  @override
  void update(void Function(BadRequestErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BadRequestError build() => _build();

  _$BadRequestError _build() {
    final _$result = _$v ??
        _$BadRequestError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'BadRequestError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'BadRequestError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
