//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:promille_zone_api/src/model/household_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_household_request.g.dart';

/// CreateHouseholdRequest
///
/// Properties:
/// * [addressText] 
/// * [householdType] 
/// * [name] 
@BuiltValue()
abstract class CreateHouseholdRequest implements Built<CreateHouseholdRequest, CreateHouseholdRequestBuilder> {
  @BuiltValueField(wireName: r'address_text')
  String get addressText;

  @BuiltValueField(wireName: r'household_type')
  HouseholdType get householdType;
  // enum householdTypeEnum {  family,  dorm,  other,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  CreateHouseholdRequest._();

  factory CreateHouseholdRequest([void updates(CreateHouseholdRequestBuilder b)]) = _$CreateHouseholdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateHouseholdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateHouseholdRequest> get serializer => _$CreateHouseholdRequestSerializer();
}

class _$CreateHouseholdRequestSerializer implements PrimitiveSerializer<CreateHouseholdRequest> {
  @override
  final Iterable<Type> types = const [CreateHouseholdRequest, _$CreateHouseholdRequest];

  @override
  final String wireName = r'CreateHouseholdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateHouseholdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'address_text';
    yield serializers.serialize(
      object.addressText,
      specifiedType: const FullType(String),
    );
    yield r'household_type';
    yield serializers.serialize(
      object.householdType,
      specifiedType: const FullType(HouseholdType),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateHouseholdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateHouseholdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'address_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.addressText = valueDes;
          break;
        case r'household_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HouseholdType),
          ) as HouseholdType;
          result.householdType = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateHouseholdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateHouseholdRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

