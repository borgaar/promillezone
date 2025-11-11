//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'household_type.g.dart';

class HouseholdType extends EnumClass {

  /// Household type for API requests and responses
  @BuiltValueEnumConst(wireName: r'family')
  static const HouseholdType family = _$family;
  /// Household type for API requests and responses
  @BuiltValueEnumConst(wireName: r'dorm')
  static const HouseholdType dorm = _$dorm;
  /// Household type for API requests and responses
  @BuiltValueEnumConst(wireName: r'other')
  static const HouseholdType other = _$other;

  static Serializer<HouseholdType> get serializer => _$householdTypeSerializer;

  const HouseholdType._(String name): super(name);

  static BuiltSet<HouseholdType> get values => _$values;
  static HouseholdType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class HouseholdTypeMixin = Object with _$HouseholdTypeMixin;

