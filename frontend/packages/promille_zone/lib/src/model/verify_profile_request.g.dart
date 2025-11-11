// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_profile_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyProfileRequest extends VerifyProfileRequest {
  @override
  final String code;

  factory _$VerifyProfileRequest(
          [void Function(VerifyProfileRequestBuilder)? updates]) =>
      (VerifyProfileRequestBuilder()..update(updates))._build();

  _$VerifyProfileRequest._({required this.code}) : super._();
  @override
  VerifyProfileRequest rebuild(
          void Function(VerifyProfileRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyProfileRequestBuilder toBuilder() =>
      VerifyProfileRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyProfileRequest && code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyProfileRequest')
          ..add('code', code))
        .toString();
  }
}

class VerifyProfileRequestBuilder
    implements Builder<VerifyProfileRequest, VerifyProfileRequestBuilder> {
  _$VerifyProfileRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  VerifyProfileRequestBuilder() {
    VerifyProfileRequest._defaults(this);
  }

  VerifyProfileRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyProfileRequest other) {
    _$v = other as _$VerifyProfileRequest;
  }

  @override
  void update(void Function(VerifyProfileRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyProfileRequest build() => _build();

  _$VerifyProfileRequest _build() {
    final _$result = _$v ??
        _$VerifyProfileRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'VerifyProfileRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
