// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HouseholdType _$family = const HouseholdType._('family');
const HouseholdType _$dorm = const HouseholdType._('dorm');
const HouseholdType _$other = const HouseholdType._('other');

HouseholdType _$valueOf(String name) {
  switch (name) {
    case 'family':
      return _$family;
    case 'dorm':
      return _$dorm;
    case 'other':
      return _$other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HouseholdType> _$values =
    BuiltSet<HouseholdType>(const <HouseholdType>[
  _$family,
  _$dorm,
  _$other,
]);

class _$HouseholdTypeMeta {
  const _$HouseholdTypeMeta();
  HouseholdType get family => _$family;
  HouseholdType get dorm => _$dorm;
  HouseholdType get other => _$other;
  HouseholdType valueOf(String name) => _$valueOf(name);
  BuiltSet<HouseholdType> get values => _$values;
}

abstract class _$HouseholdTypeMixin {
  // ignore: non_constant_identifier_names
  _$HouseholdTypeMeta get HouseholdType => const _$HouseholdTypeMeta();
}

Serializer<HouseholdType> _$householdTypeSerializer =
    _$HouseholdTypeSerializer();

class _$HouseholdTypeSerializer implements PrimitiveSerializer<HouseholdType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'family': 'family',
    'dorm': 'dorm',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'family': 'family',
    'dorm': 'dorm',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[HouseholdType];
  @override
  final String wireName = 'HouseholdType';

  @override
  Object serialize(Serializers serializers, HouseholdType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  HouseholdType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      HouseholdType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
