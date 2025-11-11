// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InviteCodeResponse extends InviteCodeResponse {
  @override
  final String code;
  @override
  final DateTime expiresAt;
  @override
  final String householdId;

  factory _$InviteCodeResponse(
          [void Function(InviteCodeResponseBuilder)? updates]) =>
      (InviteCodeResponseBuilder()..update(updates))._build();

  _$InviteCodeResponse._(
      {required this.code, required this.expiresAt, required this.householdId})
      : super._();
  @override
  InviteCodeResponse rebuild(
          void Function(InviteCodeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InviteCodeResponseBuilder toBuilder() =>
      InviteCodeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InviteCodeResponse &&
        code == other.code &&
        expiresAt == other.expiresAt &&
        householdId == other.householdId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, householdId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InviteCodeResponse')
          ..add('code', code)
          ..add('expiresAt', expiresAt)
          ..add('householdId', householdId))
        .toString();
  }
}

class InviteCodeResponseBuilder
    implements Builder<InviteCodeResponse, InviteCodeResponseBuilder> {
  _$InviteCodeResponse? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _householdId;
  String? get householdId => _$this._householdId;
  set householdId(String? householdId) => _$this._householdId = householdId;

  InviteCodeResponseBuilder() {
    InviteCodeResponse._defaults(this);
  }

  InviteCodeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _expiresAt = $v.expiresAt;
      _householdId = $v.householdId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InviteCodeResponse other) {
    _$v = other as _$InviteCodeResponse;
  }

  @override
  void update(void Function(InviteCodeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InviteCodeResponse build() => _build();

  _$InviteCodeResponse _build() {
    final _$result = _$v ??
        _$InviteCodeResponse._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'InviteCodeResponse', 'code'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'InviteCodeResponse', 'expiresAt'),
          householdId: BuiltValueNullFieldError.checkNotNull(
              householdId, r'InviteCodeResponse', 'householdId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
