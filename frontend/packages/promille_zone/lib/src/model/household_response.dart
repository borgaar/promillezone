//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:promille_zone_api/src/model/household_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'household_response.g.dart';

/// HouseholdResponse
///
/// Properties:
/// * [addressText] 
/// * [createdAt] 
/// * [householdType] 
/// * [id] 
/// * [name] 
/// * [updatedAt] 
@BuiltValue()
abstract class HouseholdResponse implements Built<HouseholdResponse, HouseholdResponseBuilder> {
  @BuiltValueField(wireName: r'address_text')
  String get addressText;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'household_type')
  HouseholdType get householdType;
  // enum householdTypeEnum {  family,  dorm,  other,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  HouseholdResponse._();

  factory HouseholdResponse([void updates(HouseholdResponseBuilder b)]) = _$HouseholdResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(HouseholdResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<HouseholdResponse> get serializer => _$HouseholdResponseSerializer();
}

class _$HouseholdResponseSerializer implements PrimitiveSerializer<HouseholdResponse> {
  @override
  final Iterable<Type> types = const [HouseholdResponse, _$HouseholdResponse];

  @override
  final String wireName = r'HouseholdResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    HouseholdResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'address_text';
    yield serializers.serialize(
      object.addressText,
      specifiedType: const FullType(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'household_type';
    yield serializers.serialize(
      object.householdType,
      specifiedType: const FullType(HouseholdType),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    HouseholdResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required HouseholdResponseBuilder result,
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
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'household_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(HouseholdType),
          ) as HouseholdType;
          result.householdType = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  HouseholdResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = HouseholdResponseBuilder();
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

