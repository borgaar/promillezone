// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConflictError extends ConflictError {
  @override
  final String code;
  @override
  final String message;

  factory _$ConflictError([void Function(ConflictErrorBuilder)? updates]) =>
      (ConflictErrorBuilder()..update(updates))._build();

  _$ConflictError._({required this.code, required this.message}) : super._();
  @override
  ConflictError rebuild(void Function(ConflictErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConflictErrorBuilder toBuilder() => ConflictErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConflictError &&
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
    return (newBuiltValueToStringHelper(r'ConflictError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class ConflictErrorBuilder
    implements Builder<ConflictError, ConflictErrorBuilder> {
  _$ConflictError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ConflictErrorBuilder() {
    ConflictError._defaults(this);
  }

  ConflictErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConflictError other) {
    _$v = other as _$ConflictError;
  }

  @override
  void update(void Function(ConflictErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConflictError build() => _build();

  _$ConflictError _build() {
    final _$result = _$v ??
        _$ConflictError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ConflictError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'ConflictError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
