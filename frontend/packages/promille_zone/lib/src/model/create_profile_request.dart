//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_profile_request.g.dart';

/// CreateProfileRequest
///
/// Properties:
/// * [firstName] 
/// * [lastName] 
@BuiltValue()
abstract class CreateProfileRequest implements Built<CreateProfileRequest, CreateProfileRequestBuilder> {
  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'last_name')
  String get lastName;

  CreateProfileRequest._();

  factory CreateProfileRequest([void updates(CreateProfileRequestBuilder b)]) = _$CreateProfileRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateProfileRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateProfileRequest> get serializer => _$CreateProfileRequestSerializer();
}

class _$CreateProfileRequestSerializer implements PrimitiveSerializer<CreateProfileRequest> {
  @override
  final Iterable<Type> types = const [CreateProfileRequest, _$CreateProfileRequest];

  @override
  final String wireName = r'CreateProfileRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateProfileRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'first_name';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'last_name';
    yield serializers.serialize(
      object.lastName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateProfileRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateProfileRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'last_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lastName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateProfileRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateProfileRequestBuilder();
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

