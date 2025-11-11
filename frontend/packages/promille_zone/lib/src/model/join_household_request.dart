//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'join_household_request.g.dart';

/// JoinHouseholdRequest
///
/// Properties:
/// * [code] 
@BuiltValue()
abstract class JoinHouseholdRequest implements Built<JoinHouseholdRequest, JoinHouseholdRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  JoinHouseholdRequest._();

  factory JoinHouseholdRequest([void updates(JoinHouseholdRequestBuilder b)]) = _$JoinHouseholdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(JoinHouseholdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<JoinHouseholdRequest> get serializer => _$JoinHouseholdRequestSerializer();
}

class _$JoinHouseholdRequestSerializer implements PrimitiveSerializer<JoinHouseholdRequest> {
  @override
  final Iterable<Type> types = const [JoinHouseholdRequest, _$JoinHouseholdRequest];

  @override
  final String wireName = r'JoinHouseholdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    JoinHouseholdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    JoinHouseholdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required JoinHouseholdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  JoinHouseholdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = JoinHouseholdRequestBuilder();
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

