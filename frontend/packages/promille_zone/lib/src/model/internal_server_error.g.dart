// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'internal_server_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InternalServerError extends InternalServerError {
  @override
  final String code;
  @override
  final String message;

  factory _$InternalServerError(
          [void Function(InternalServerErrorBuilder)? updates]) =>
      (InternalServerErrorBuilder()..update(updates))._build();

  _$InternalServerError._({required this.code, required this.message})
      : super._();
  @override
  InternalServerError rebuild(
          void Function(InternalServerErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InternalServerErrorBuilder toBuilder() =>
      InternalServerErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InternalServerError &&
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
    return (newBuiltValueToStringHelper(r'InternalServerError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class InternalServerErrorBuilder
    implements Builder<InternalServerError, InternalServerErrorBuilder> {
  _$InternalServerError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  InternalServerErrorBuilder() {
    InternalServerError._defaults(this);
  }

  InternalServerErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InternalServerError other) {
    _$v = other as _$InternalServerError;
  }

  @override
  void update(void Function(InternalServerErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InternalServerError build() => _build();

  _$InternalServerError _build() {
    final _$result = _$v ??
        _$InternalServerError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'InternalServerError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'InternalServerError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
