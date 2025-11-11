//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'invite_code_response.g.dart';

/// InviteCodeResponse
///
/// Properties:
/// * [code] 
/// * [expiresAt] 
/// * [householdId] 
@BuiltValue()
abstract class InviteCodeResponse implements Built<InviteCodeResponse, InviteCodeResponseBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'household_id')
  String get householdId;

  InviteCodeResponse._();

  factory InviteCodeResponse([void updates(InviteCodeResponseBuilder b)]) = _$InviteCodeResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(InviteCodeResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<InviteCodeResponse> get serializer => _$InviteCodeResponseSerializer();
}

class _$InviteCodeResponseSerializer implements PrimitiveSerializer<InviteCodeResponse> {
  @override
  final Iterable<Type> types = const [InviteCodeResponse, _$InviteCodeResponse];

  @override
  final String wireName = r'InviteCodeResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    InviteCodeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'household_id';
    yield serializers.serialize(
      object.householdId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    InviteCodeResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required InviteCodeResponseBuilder result,
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
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'household_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.householdId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  InviteCodeResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = InviteCodeResponseBuilder();
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

