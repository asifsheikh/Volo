// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flight_confirmation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FlightConfirmationState {
  String get fromCity => throw _privateConstructorUsedError;
  String get toCity => throw _privateConstructorUsedError;
  List<String> get contactNames => throw _privateConstructorUsedError;
  List<String> get contactAvatars => throw _privateConstructorUsedError;
  dynamic get selectedFlight => throw _privateConstructorUsedError;
  String get departureAirportCode => throw _privateConstructorUsedError;
  String get departureImage => throw _privateConstructorUsedError;
  String get departureThumbnail => throw _privateConstructorUsedError;
  String get arrivalAirportCode => throw _privateConstructorUsedError;
  String get arrivalImage => throw _privateConstructorUsedError;
  String get arrivalThumbnail => throw _privateConstructorUsedError;
  bool get enableNotifications => throw _privateConstructorUsedError;
  bool get hasShownConfetti => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FlightConfirmationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlightConfirmationStateCopyWith<FlightConfirmationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlightConfirmationStateCopyWith<$Res> {
  factory $FlightConfirmationStateCopyWith(
    FlightConfirmationState value,
    $Res Function(FlightConfirmationState) then,
  ) = _$FlightConfirmationStateCopyWithImpl<$Res, FlightConfirmationState>;
  @useResult
  $Res call({
    String fromCity,
    String toCity,
    List<String> contactNames,
    List<String> contactAvatars,
    dynamic selectedFlight,
    String departureAirportCode,
    String departureImage,
    String departureThumbnail,
    String arrivalAirportCode,
    String arrivalImage,
    String arrivalThumbnail,
    bool enableNotifications,
    bool hasShownConfetti,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$FlightConfirmationStateCopyWithImpl<
  $Res,
  $Val extends FlightConfirmationState
>
    implements $FlightConfirmationStateCopyWith<$Res> {
  _$FlightConfirmationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlightConfirmationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromCity = null,
    Object? toCity = null,
    Object? contactNames = null,
    Object? contactAvatars = null,
    Object? selectedFlight = freezed,
    Object? departureAirportCode = null,
    Object? departureImage = null,
    Object? departureThumbnail = null,
    Object? arrivalAirportCode = null,
    Object? arrivalImage = null,
    Object? arrivalThumbnail = null,
    Object? enableNotifications = null,
    Object? hasShownConfetti = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            fromCity: null == fromCity
                ? _value.fromCity
                : fromCity // ignore: cast_nullable_to_non_nullable
                      as String,
            toCity: null == toCity
                ? _value.toCity
                : toCity // ignore: cast_nullable_to_non_nullable
                      as String,
            contactNames: null == contactNames
                ? _value.contactNames
                : contactNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            contactAvatars: null == contactAvatars
                ? _value.contactAvatars
                : contactAvatars // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            selectedFlight: freezed == selectedFlight
                ? _value.selectedFlight
                : selectedFlight // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            departureAirportCode: null == departureAirportCode
                ? _value.departureAirportCode
                : departureAirportCode // ignore: cast_nullable_to_non_nullable
                      as String,
            departureImage: null == departureImage
                ? _value.departureImage
                : departureImage // ignore: cast_nullable_to_non_nullable
                      as String,
            departureThumbnail: null == departureThumbnail
                ? _value.departureThumbnail
                : departureThumbnail // ignore: cast_nullable_to_non_nullable
                      as String,
            arrivalAirportCode: null == arrivalAirportCode
                ? _value.arrivalAirportCode
                : arrivalAirportCode // ignore: cast_nullable_to_non_nullable
                      as String,
            arrivalImage: null == arrivalImage
                ? _value.arrivalImage
                : arrivalImage // ignore: cast_nullable_to_non_nullable
                      as String,
            arrivalThumbnail: null == arrivalThumbnail
                ? _value.arrivalThumbnail
                : arrivalThumbnail // ignore: cast_nullable_to_non_nullable
                      as String,
            enableNotifications: null == enableNotifications
                ? _value.enableNotifications
                : enableNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasShownConfetti: null == hasShownConfetti
                ? _value.hasShownConfetti
                : hasShownConfetti // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlightConfirmationStateImplCopyWith<$Res>
    implements $FlightConfirmationStateCopyWith<$Res> {
  factory _$$FlightConfirmationStateImplCopyWith(
    _$FlightConfirmationStateImpl value,
    $Res Function(_$FlightConfirmationStateImpl) then,
  ) = __$$FlightConfirmationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fromCity,
    String toCity,
    List<String> contactNames,
    List<String> contactAvatars,
    dynamic selectedFlight,
    String departureAirportCode,
    String departureImage,
    String departureThumbnail,
    String arrivalAirportCode,
    String arrivalImage,
    String arrivalThumbnail,
    bool enableNotifications,
    bool hasShownConfetti,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$FlightConfirmationStateImplCopyWithImpl<$Res>
    extends
        _$FlightConfirmationStateCopyWithImpl<
          $Res,
          _$FlightConfirmationStateImpl
        >
    implements _$$FlightConfirmationStateImplCopyWith<$Res> {
  __$$FlightConfirmationStateImplCopyWithImpl(
    _$FlightConfirmationStateImpl _value,
    $Res Function(_$FlightConfirmationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlightConfirmationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromCity = null,
    Object? toCity = null,
    Object? contactNames = null,
    Object? contactAvatars = null,
    Object? selectedFlight = freezed,
    Object? departureAirportCode = null,
    Object? departureImage = null,
    Object? departureThumbnail = null,
    Object? arrivalAirportCode = null,
    Object? arrivalImage = null,
    Object? arrivalThumbnail = null,
    Object? enableNotifications = null,
    Object? hasShownConfetti = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$FlightConfirmationStateImpl(
        fromCity: null == fromCity
            ? _value.fromCity
            : fromCity // ignore: cast_nullable_to_non_nullable
                  as String,
        toCity: null == toCity
            ? _value.toCity
            : toCity // ignore: cast_nullable_to_non_nullable
                  as String,
        contactNames: null == contactNames
            ? _value._contactNames
            : contactNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        contactAvatars: null == contactAvatars
            ? _value._contactAvatars
            : contactAvatars // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        selectedFlight: freezed == selectedFlight
            ? _value.selectedFlight
            : selectedFlight // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        departureAirportCode: null == departureAirportCode
            ? _value.departureAirportCode
            : departureAirportCode // ignore: cast_nullable_to_non_nullable
                  as String,
        departureImage: null == departureImage
            ? _value.departureImage
            : departureImage // ignore: cast_nullable_to_non_nullable
                  as String,
        departureThumbnail: null == departureThumbnail
            ? _value.departureThumbnail
            : departureThumbnail // ignore: cast_nullable_to_non_nullable
                  as String,
        arrivalAirportCode: null == arrivalAirportCode
            ? _value.arrivalAirportCode
            : arrivalAirportCode // ignore: cast_nullable_to_non_nullable
                  as String,
        arrivalImage: null == arrivalImage
            ? _value.arrivalImage
            : arrivalImage // ignore: cast_nullable_to_non_nullable
                  as String,
        arrivalThumbnail: null == arrivalThumbnail
            ? _value.arrivalThumbnail
            : arrivalThumbnail // ignore: cast_nullable_to_non_nullable
                  as String,
        enableNotifications: null == enableNotifications
            ? _value.enableNotifications
            : enableNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasShownConfetti: null == hasShownConfetti
            ? _value.hasShownConfetti
            : hasShownConfetti // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$FlightConfirmationStateImpl implements _FlightConfirmationState {
  const _$FlightConfirmationStateImpl({
    required this.fromCity,
    required this.toCity,
    required final List<String> contactNames,
    required final List<String> contactAvatars,
    this.selectedFlight,
    required this.departureAirportCode,
    required this.departureImage,
    required this.departureThumbnail,
    required this.arrivalAirportCode,
    required this.arrivalImage,
    required this.arrivalThumbnail,
    this.enableNotifications = false,
    this.hasShownConfetti = false,
    this.isLoading = false,
    this.errorMessage,
  }) : _contactNames = contactNames,
       _contactAvatars = contactAvatars;

  @override
  final String fromCity;
  @override
  final String toCity;
  final List<String> _contactNames;
  @override
  List<String> get contactNames {
    if (_contactNames is EqualUnmodifiableListView) return _contactNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contactNames);
  }

  final List<String> _contactAvatars;
  @override
  List<String> get contactAvatars {
    if (_contactAvatars is EqualUnmodifiableListView) return _contactAvatars;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contactAvatars);
  }

  @override
  final dynamic selectedFlight;
  @override
  final String departureAirportCode;
  @override
  final String departureImage;
  @override
  final String departureThumbnail;
  @override
  final String arrivalAirportCode;
  @override
  final String arrivalImage;
  @override
  final String arrivalThumbnail;
  @override
  @JsonKey()
  final bool enableNotifications;
  @override
  @JsonKey()
  final bool hasShownConfetti;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'FlightConfirmationState(fromCity: $fromCity, toCity: $toCity, contactNames: $contactNames, contactAvatars: $contactAvatars, selectedFlight: $selectedFlight, departureAirportCode: $departureAirportCode, departureImage: $departureImage, departureThumbnail: $departureThumbnail, arrivalAirportCode: $arrivalAirportCode, arrivalImage: $arrivalImage, arrivalThumbnail: $arrivalThumbnail, enableNotifications: $enableNotifications, hasShownConfetti: $hasShownConfetti, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlightConfirmationStateImpl &&
            (identical(other.fromCity, fromCity) ||
                other.fromCity == fromCity) &&
            (identical(other.toCity, toCity) || other.toCity == toCity) &&
            const DeepCollectionEquality().equals(
              other._contactNames,
              _contactNames,
            ) &&
            const DeepCollectionEquality().equals(
              other._contactAvatars,
              _contactAvatars,
            ) &&
            const DeepCollectionEquality().equals(
              other.selectedFlight,
              selectedFlight,
            ) &&
            (identical(other.departureAirportCode, departureAirportCode) ||
                other.departureAirportCode == departureAirportCode) &&
            (identical(other.departureImage, departureImage) ||
                other.departureImage == departureImage) &&
            (identical(other.departureThumbnail, departureThumbnail) ||
                other.departureThumbnail == departureThumbnail) &&
            (identical(other.arrivalAirportCode, arrivalAirportCode) ||
                other.arrivalAirportCode == arrivalAirportCode) &&
            (identical(other.arrivalImage, arrivalImage) ||
                other.arrivalImage == arrivalImage) &&
            (identical(other.arrivalThumbnail, arrivalThumbnail) ||
                other.arrivalThumbnail == arrivalThumbnail) &&
            (identical(other.enableNotifications, enableNotifications) ||
                other.enableNotifications == enableNotifications) &&
            (identical(other.hasShownConfetti, hasShownConfetti) ||
                other.hasShownConfetti == hasShownConfetti) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    fromCity,
    toCity,
    const DeepCollectionEquality().hash(_contactNames),
    const DeepCollectionEquality().hash(_contactAvatars),
    const DeepCollectionEquality().hash(selectedFlight),
    departureAirportCode,
    departureImage,
    departureThumbnail,
    arrivalAirportCode,
    arrivalImage,
    arrivalThumbnail,
    enableNotifications,
    hasShownConfetti,
    isLoading,
    errorMessage,
  );

  /// Create a copy of FlightConfirmationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlightConfirmationStateImplCopyWith<_$FlightConfirmationStateImpl>
  get copyWith =>
      __$$FlightConfirmationStateImplCopyWithImpl<
        _$FlightConfirmationStateImpl
      >(this, _$identity);
}

abstract class _FlightConfirmationState implements FlightConfirmationState {
  const factory _FlightConfirmationState({
    required final String fromCity,
    required final String toCity,
    required final List<String> contactNames,
    required final List<String> contactAvatars,
    final dynamic selectedFlight,
    required final String departureAirportCode,
    required final String departureImage,
    required final String departureThumbnail,
    required final String arrivalAirportCode,
    required final String arrivalImage,
    required final String arrivalThumbnail,
    final bool enableNotifications,
    final bool hasShownConfetti,
    final bool isLoading,
    final String? errorMessage,
  }) = _$FlightConfirmationStateImpl;

  @override
  String get fromCity;
  @override
  String get toCity;
  @override
  List<String> get contactNames;
  @override
  List<String> get contactAvatars;
  @override
  dynamic get selectedFlight;
  @override
  String get departureAirportCode;
  @override
  String get departureImage;
  @override
  String get departureThumbnail;
  @override
  String get arrivalAirportCode;
  @override
  String get arrivalImage;
  @override
  String get arrivalThumbnail;
  @override
  bool get enableNotifications;
  @override
  bool get hasShownConfetti;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of FlightConfirmationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlightConfirmationStateImplCopyWith<_$FlightConfirmationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
