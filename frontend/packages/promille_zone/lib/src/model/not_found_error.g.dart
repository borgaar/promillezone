// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'not_found_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotFoundError extends NotFoundError {
  @override
  final String code;
  @override
  final String message;

  factory _$NotFoundError([void Function(NotFoundErrorBuilder)? updates]) =>
      (NotFoundErrorBuilder()..update(updates))._build();

  _$NotFoundError._({required this.code, required this.message}) : super._();
  @override
  NotFoundError rebuild(void Function(NotFoundErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotFoundErrorBuilder toBuilder() => NotFoundErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotFoundError &&
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
    return (newBuiltValueToStringHelper(r'NotFoundError')
          ..add('code', code)
          ..add('message', message))
        .toString();
  }
}

class NotFoundErrorBuilder
    implements Builder<NotFoundError, NotFoundErrorBuilder> {
  _$NotFoundError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  NotFoundErrorBuilder() {
    NotFoundError._defaults(this);
  }

  NotFoundErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotFoundError other) {
    _$v = other as _$NotFoundError;
  }

  @override
  void update(void Function(NotFoundErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotFoundError build() => _build();

  _$NotFoundError _build() {
    final _$result = _$v ??
        _$NotFoundError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'NotFoundError', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'NotFoundError', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
