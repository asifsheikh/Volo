// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_circle_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MyCircleContact _$MyCircleContactFromJson(Map<String, dynamic> json) {
  return _MyCircleContact.fromJson(json);
}

/// @nodoc
mixin _$MyCircleContact {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get whatsappNumber => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  /// Serializes this MyCircleContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyCircleContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyCircleContactCopyWith<MyCircleContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyCircleContactCopyWith<$Res> {
  factory $MyCircleContactCopyWith(
    MyCircleContact value,
    $Res Function(MyCircleContact) then,
  ) = _$MyCircleContactCopyWithImpl<$Res, MyCircleContact>;
  @useResult
  $Res call({
    String id,
    String name,
    String whatsappNumber,
    String timezone,
    String language,
  });
}

/// @nodoc
class _$MyCircleContactCopyWithImpl<$Res, $Val extends MyCircleContact>
    implements $MyCircleContactCopyWith<$Res> {
  _$MyCircleContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyCircleContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? whatsappNumber = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappNumber: null == whatsappNumber
                ? _value.whatsappNumber
                : whatsappNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyCircleContactImplCopyWith<$Res>
    implements $MyCircleContactCopyWith<$Res> {
  factory _$$MyCircleContactImplCopyWith(
    _$MyCircleContactImpl value,
    $Res Function(_$MyCircleContactImpl) then,
  ) = __$$MyCircleContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String whatsappNumber,
    String timezone,
    String language,
  });
}

/// @nodoc
class __$$MyCircleContactImplCopyWithImpl<$Res>
    extends _$MyCircleContactCopyWithImpl<$Res, _$MyCircleContactImpl>
    implements _$$MyCircleContactImplCopyWith<$Res> {
  __$$MyCircleContactImplCopyWithImpl(
    _$MyCircleContactImpl _value,
    $Res Function(_$MyCircleContactImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyCircleContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? whatsappNumber = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _$MyCircleContactImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappNumber: null == whatsappNumber
            ? _value.whatsappNumber
            : whatsappNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MyCircleContactImpl implements _MyCircleContact {
  const _$MyCircleContactImpl({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.timezone,
    required this.language,
  });

  factory _$MyCircleContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyCircleContactImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String whatsappNumber;
  @override
  final String timezone;
  @override
  final String language;

  @override
  String toString() {
    return 'MyCircleContact(id: $id, name: $name, whatsappNumber: $whatsappNumber, timezone: $timezone, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyCircleContactImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, whatsappNumber, timezone, language);

  /// Create a copy of MyCircleContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyCircleContactImplCopyWith<_$MyCircleContactImpl> get copyWith =>
      __$$MyCircleContactImplCopyWithImpl<_$MyCircleContactImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MyCircleContactImplToJson(this);
  }
}

abstract class _MyCircleContact implements MyCircleContact {
  const factory _MyCircleContact({
    required final String id,
    required final String name,
    required final String whatsappNumber,
    required final String timezone,
    required final String language,
  }) = _$MyCircleContactImpl;

  factory _MyCircleContact.fromJson(Map<String, dynamic> json) =
      _$MyCircleContactImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get whatsappNumber;
  @override
  String get timezone;
  @override
  String get language;

  /// Create a copy of MyCircleContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyCircleContactImplCopyWith<_$MyCircleContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MyCircleContactForm {
  String get name => throw _privateConstructorUsedError;
  String get whatsappNumber => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;

  /// Create a copy of MyCircleContactForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyCircleContactFormCopyWith<MyCircleContactForm> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyCircleContactFormCopyWith<$Res> {
  factory $MyCircleContactFormCopyWith(
    MyCircleContactForm value,
    $Res Function(MyCircleContactForm) then,
  ) = _$MyCircleContactFormCopyWithImpl<$Res, MyCircleContactForm>;
  @useResult
  $Res call({
    String name,
    String whatsappNumber,
    String timezone,
    String language,
  });
}

/// @nodoc
class _$MyCircleContactFormCopyWithImpl<$Res, $Val extends MyCircleContactForm>
    implements $MyCircleContactFormCopyWith<$Res> {
  _$MyCircleContactFormCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyCircleContactForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? whatsappNumber = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            whatsappNumber: null == whatsappNumber
                ? _value.whatsappNumber
                : whatsappNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyCircleContactFormImplCopyWith<$Res>
    implements $MyCircleContactFormCopyWith<$Res> {
  factory _$$MyCircleContactFormImplCopyWith(
    _$MyCircleContactFormImpl value,
    $Res Function(_$MyCircleContactFormImpl) then,
  ) = __$$MyCircleContactFormImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String whatsappNumber,
    String timezone,
    String language,
  });
}

/// @nodoc
class __$$MyCircleContactFormImplCopyWithImpl<$Res>
    extends _$MyCircleContactFormCopyWithImpl<$Res, _$MyCircleContactFormImpl>
    implements _$$MyCircleContactFormImplCopyWith<$Res> {
  __$$MyCircleContactFormImplCopyWithImpl(
    _$MyCircleContactFormImpl _value,
    $Res Function(_$MyCircleContactFormImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyCircleContactForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? whatsappNumber = null,
    Object? timezone = null,
    Object? language = null,
  }) {
    return _then(
      _$MyCircleContactFormImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        whatsappNumber: null == whatsappNumber
            ? _value.whatsappNumber
            : whatsappNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MyCircleContactFormImpl implements _MyCircleContactForm {
  const _$MyCircleContactFormImpl({
    required this.name,
    required this.whatsappNumber,
    required this.timezone,
    required this.language,
  });

  @override
  final String name;
  @override
  final String whatsappNumber;
  @override
  final String timezone;
  @override
  final String language;

  @override
  String toString() {
    return 'MyCircleContactForm(name: $name, whatsappNumber: $whatsappNumber, timezone: $timezone, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyCircleContactFormImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, whatsappNumber, timezone, language);

  /// Create a copy of MyCircleContactForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyCircleContactFormImplCopyWith<_$MyCircleContactFormImpl> get copyWith =>
      __$$MyCircleContactFormImplCopyWithImpl<_$MyCircleContactFormImpl>(
        this,
        _$identity,
      );
}

abstract class _MyCircleContactForm implements MyCircleContactForm {
  const factory _MyCircleContactForm({
    required final String name,
    required final String whatsappNumber,
    required final String timezone,
    required final String language,
  }) = _$MyCircleContactFormImpl;

  @override
  String get name;
  @override
  String get whatsappNumber;
  @override
  String get timezone;
  @override
  String get language;

  /// Create a copy of MyCircleContactForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyCircleContactFormImplCopyWith<_$MyCircleContactFormImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
