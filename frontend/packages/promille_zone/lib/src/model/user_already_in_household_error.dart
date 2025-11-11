//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_already_in_household_error.g.dart';

/// UserAlreadyInHouseholdError
///
/// Properties:
/// * [code] 
/// * [message] 
@BuiltValue()
abstract class UserAlreadyInHouseholdError implements Built<UserAlreadyInHouseholdError, UserAlreadyInHouseholdErrorBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'message')
  String get message;

  UserAlreadyInHouseholdError._();

  factory UserAlreadyInHouseholdError([void updates(UserAlreadyInHouseholdErrorBuilder b)]) = _$UserAlreadyInHouseholdError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserAlreadyInHouseholdErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserAlreadyInHouseholdError> get serializer => _$UserAlreadyInHouseholdErrorSerializer();
}

class _$UserAlreadyInHouseholdErrorSerializer implements PrimitiveSerializer<UserAlreadyInHouseholdError> {
  @override
  final Iterable<Type> types = const [UserAlreadyInHouseholdError, _$UserAlreadyInHouseholdError];

  @override
  final String wireName = r'UserAlreadyInHouseholdError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserAlreadyInHouseholdError object, {
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
    UserAlreadyInHouseholdError object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserAlreadyInHouseholdErrorBuilder result,
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
  UserAlreadyInHouseholdError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserAlreadyInHouseholdErrorBuilder();
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

