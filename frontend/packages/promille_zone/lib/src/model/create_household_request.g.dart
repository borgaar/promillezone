// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_household_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateHouseholdRequest extends CreateHouseholdRequest {
  @override
  final String addressText;
  @override
  final HouseholdType householdType;
  @override
  final String name;

  factory _$CreateHouseholdRequest(
          [void Function(CreateHouseholdRequestBuilder)? updates]) =>
      (CreateHouseholdRequestBuilder()..update(updates))._build();

  _$CreateHouseholdRequest._(
      {required this.addressText,
      required this.householdType,
      required this.name})
      : super._();
  @override
  CreateHouseholdRequest rebuild(
          void Function(CreateHouseholdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateHouseholdRequestBuilder toBuilder() =>
      CreateHouseholdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateHouseholdRequest &&
        addressText == other.addressText &&
        householdType == other.householdType &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, addressText.hashCode);
    _$hash = $jc(_$hash, householdType.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateHouseholdRequest')
          ..add('addressText', addressText)
          ..add('householdType', householdType)
          ..add('name', name))
        .toString();
  }
}

class CreateHouseholdRequestBuilder
    implements Builder<CreateHouseholdRequest, CreateHouseholdRequestBuilder> {
  _$CreateHouseholdRequest? _$v;

  String? _addressText;
  String? get addressText => _$this._addressText;
  set addressText(String? addressText) => _$this._addressText = addressText;

  HouseholdType? _householdType;
  HouseholdType? get householdType => _$this._householdType;
  set householdType(HouseholdType? householdType) =>
      _$this._householdType = householdType;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CreateHouseholdRequestBuilder() {
    CreateHouseholdRequest._defaults(this);
  }

  CreateHouseholdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _addressText = $v.addressText;
      _householdType = $v.householdType;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateHouseholdRequest other) {
    _$v = other as _$CreateHouseholdRequest;
  }

  @override
  void update(void Function(CreateHouseholdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateHouseholdRequest build() => _build();

  _$CreateHouseholdRequest _build() {
    final _$result = _$v ??
        _$CreateHouseholdRequest._(
          addressText: BuiltValueNullFieldError.checkNotNull(
              addressText, r'CreateHouseholdRequest', 'addressText'),
          householdType: BuiltValueNullFieldError.checkNotNull(
              householdType, r'CreateHouseholdRequest', 'householdType'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateHouseholdRequest', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
