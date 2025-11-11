// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_household_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JoinHouseholdRequest extends JoinHouseholdRequest {
  @override
  final String code;

  factory _$JoinHouseholdRequest(
          [void Function(JoinHouseholdRequestBuilder)? updates]) =>
      (JoinHouseholdRequestBuilder()..update(updates))._build();

  _$JoinHouseholdRequest._({required this.code}) : super._();
  @override
  JoinHouseholdRequest rebuild(
          void Function(JoinHouseholdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  JoinHouseholdRequestBuilder toBuilder() =>
      JoinHouseholdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JoinHouseholdRequest && code == other.code;
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
    return (newBuiltValueToStringHelper(r'JoinHouseholdRequest')
          ..add('code', code))
        .toString();
  }
}

class JoinHouseholdRequestBuilder
    implements Builder<JoinHouseholdRequest, JoinHouseholdRequestBuilder> {
  _$JoinHouseholdRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  JoinHouseholdRequestBuilder() {
    JoinHouseholdRequest._defaults(this);
  }

  JoinHouseholdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JoinHouseholdRequest other) {
    _$v = other as _$JoinHouseholdRequest;
  }

  @override
  void update(void Function(JoinHouseholdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JoinHouseholdRequest build() => _build();

  _$JoinHouseholdRequest _build() {
    final _$result = _$v ??
        _$JoinHouseholdRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'JoinHouseholdRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
