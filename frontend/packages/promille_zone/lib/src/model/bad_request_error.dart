//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bad_request_error.g.dart';

/// BadRequestError
///
/// Properties:
/// * [code] 
/// * [message] 
@BuiltValue()
abstract class BadRequestError implements Built<BadRequestError, BadRequestErrorBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'message')
  String get message;

  BadRequestError._();

  factory BadRequestError([void updates(BadRequestErrorBuilder b)]) = _$BadRequestError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BadRequestErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BadRequestError> get serializer => _$BadRequestErrorSerializer();
}

class _$BadRequestErrorSerializer implements PrimitiveSerializer<BadRequestError> {
  @override
  final Iterable<Type> types = const [BadRequestError, _$BadRequestError];

  @override
  final String wireName = r'BadRequestError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BadRequestError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BadRequestError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BadRequestErrorBuilder result,
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
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BadRequestError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BadRequestErrorBuilder();
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

