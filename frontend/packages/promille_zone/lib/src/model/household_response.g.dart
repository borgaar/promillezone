// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HouseholdResponse extends HouseholdResponse {
  @override
  final String addressText;
  @override
  final DateTime createdAt;
  @override
  final HouseholdType householdType;
  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime updatedAt;

  factory _$HouseholdResponse(
          [void Function(HouseholdResponseBuilder)? updates]) =>
      (HouseholdResponseBuilder()..update(updates))._build();

  _$HouseholdResponse._(
      {required this.addressText,
      required this.createdAt,
      required this.householdType,
      required this.id,
      required this.name,
      required this.updatedAt})
      : super._();
  @override
  HouseholdResponse rebuild(void Function(HouseholdResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HouseholdResponseBuilder toBuilder() =>
      HouseholdResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HouseholdResponse &&
        addressText == other.addressText &&
        createdAt == other.createdAt &&
        householdType == other.householdType &&
        id == other.id &&
        name == other.name &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, addressText.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, householdType.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HouseholdResponse')
          ..add('addressText', addressText)
          ..add('createdAt', createdAt)
          ..add('householdType', householdType)
          ..add('id', id)
          ..add('name', name)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class HouseholdResponseBuilder
    implements Builder<HouseholdResponse, HouseholdResponseBuilder> {
  _$HouseholdResponse? _$v;

  String? _addressText;
  String? get addressText => _$this._addressText;
  set addressText(String? addressText) => _$this._addressText = addressText;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  HouseholdType? _householdType;
  HouseholdType? get householdType => _$this._householdType;
  set householdType(HouseholdType? householdType) =>
      _$this._householdType = householdType;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  HouseholdResponseBuilder() {
    HouseholdResponse._defaults(this);
  }

  HouseholdResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _addressText = $v.addressText;
      _createdAt = $v.createdAt;
      _householdType = $v.householdType;
      _id = $v.id;
      _name = $v.name;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HouseholdResponse other) {
    _$v = other as _$HouseholdResponse;
  }

  @override
  void update(void Function(HouseholdResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HouseholdResponse build() => _build();

  _$HouseholdResponse _build() {
    final _$result = _$v ??
        _$HouseholdResponse._(
          addressText: BuiltValueNullFieldError.checkNotNull(
              addressText, r'HouseholdResponse', 'addressText'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'HouseholdResponse', 'createdAt'),
          householdType: BuiltValueNullFieldError.checkNotNull(
              householdType, r'HouseholdResponse', 'householdType'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'HouseholdResponse', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'HouseholdResponse', 'name'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'HouseholdResponse', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
