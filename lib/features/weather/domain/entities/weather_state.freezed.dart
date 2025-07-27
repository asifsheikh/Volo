// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeatherState _$WeatherStateFromJson(Map<String, dynamic> json) {
  return _WeatherState.fromJson(json);
}

/// @nodoc
mixin _$WeatherState {
  String get iataCode => throw _privateConstructorUsedError;
  String get cityName => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  WeatherCoordinates get coordinates => throw _privateConstructorUsedError;
  int get timezone => throw _privateConstructorUsedError;
  WeatherCurrent get current => throw _privateConstructorUsedError;

  /// Serializes this WeatherState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherStateCopyWith<WeatherState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherStateCopyWith<$Res> {
  factory $WeatherStateCopyWith(
    WeatherState value,
    $Res Function(WeatherState) then,
  ) = _$WeatherStateCopyWithImpl<$Res, WeatherState>;
  @useResult
  $Res call({
    String iataCode,
    String cityName,
    String country,
    WeatherCoordinates coordinates,
    int timezone,
    WeatherCurrent current,
  });

  $WeatherCoordinatesCopyWith<$Res> get coordinates;
  $WeatherCurrentCopyWith<$Res> get current;
}

/// @nodoc
class _$WeatherStateCopyWithImpl<$Res, $Val extends WeatherState>
    implements $WeatherStateCopyWith<$Res> {
  _$WeatherStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCode = null,
    Object? cityName = null,
    Object? country = null,
    Object? coordinates = null,
    Object? timezone = null,
    Object? current = null,
  }) {
    return _then(
      _value.copyWith(
            iataCode: null == iataCode
                ? _value.iataCode
                : iataCode // ignore: cast_nullable_to_non_nullable
                      as String,
            cityName: null == cityName
                ? _value.cityName
                : cityName // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            coordinates: null == coordinates
                ? _value.coordinates
                : coordinates // ignore: cast_nullable_to_non_nullable
                      as WeatherCoordinates,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as int,
            current: null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                      as WeatherCurrent,
          )
          as $Val,
    );
  }

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherCoordinatesCopyWith<$Res> get coordinates {
    return $WeatherCoordinatesCopyWith<$Res>(_value.coordinates, (value) {
      return _then(_value.copyWith(coordinates: value) as $Val);
    });
  }

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherCurrentCopyWith<$Res> get current {
    return $WeatherCurrentCopyWith<$Res>(_value.current, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherStateImplCopyWith<$Res>
    implements $WeatherStateCopyWith<$Res> {
  factory _$$WeatherStateImplCopyWith(
    _$WeatherStateImpl value,
    $Res Function(_$WeatherStateImpl) then,
  ) = __$$WeatherStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String iataCode,
    String cityName,
    String country,
    WeatherCoordinates coordinates,
    int timezone,
    WeatherCurrent current,
  });

  @override
  $WeatherCoordinatesCopyWith<$Res> get coordinates;
  @override
  $WeatherCurrentCopyWith<$Res> get current;
}

/// @nodoc
class __$$WeatherStateImplCopyWithImpl<$Res>
    extends _$WeatherStateCopyWithImpl<$Res, _$WeatherStateImpl>
    implements _$$WeatherStateImplCopyWith<$Res> {
  __$$WeatherStateImplCopyWithImpl(
    _$WeatherStateImpl _value,
    $Res Function(_$WeatherStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCode = null,
    Object? cityName = null,
    Object? country = null,
    Object? coordinates = null,
    Object? timezone = null,
    Object? current = null,
  }) {
    return _then(
      _$WeatherStateImpl(
        iataCode: null == iataCode
            ? _value.iataCode
            : iataCode // ignore: cast_nullable_to_non_nullable
                  as String,
        cityName: null == cityName
            ? _value.cityName
            : cityName // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        coordinates: null == coordinates
            ? _value.coordinates
            : coordinates // ignore: cast_nullable_to_non_nullable
                  as WeatherCoordinates,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as int,
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as WeatherCurrent,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherStateImpl implements _WeatherState {
  const _$WeatherStateImpl({
    required this.iataCode,
    required this.cityName,
    required this.country,
    required this.coordinates,
    required this.timezone,
    required this.current,
  });

  factory _$WeatherStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherStateImplFromJson(json);

  @override
  final String iataCode;
  @override
  final String cityName;
  @override
  final String country;
  @override
  final WeatherCoordinates coordinates;
  @override
  final int timezone;
  @override
  final WeatherCurrent current;

  @override
  String toString() {
    return 'WeatherState(iataCode: $iataCode, cityName: $cityName, country: $country, coordinates: $coordinates, timezone: $timezone, current: $current)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherStateImpl &&
            (identical(other.iataCode, iataCode) ||
                other.iataCode == iataCode) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.current, current) || other.current == current));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    iataCode,
    cityName,
    country,
    coordinates,
    timezone,
    current,
  );

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherStateImplCopyWith<_$WeatherStateImpl> get copyWith =>
      __$$WeatherStateImplCopyWithImpl<_$WeatherStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherStateImplToJson(this);
  }
}

abstract class _WeatherState implements WeatherState {
  const factory _WeatherState({
    required final String iataCode,
    required final String cityName,
    required final String country,
    required final WeatherCoordinates coordinates,
    required final int timezone,
    required final WeatherCurrent current,
  }) = _$WeatherStateImpl;

  factory _WeatherState.fromJson(Map<String, dynamic> json) =
      _$WeatherStateImpl.fromJson;

  @override
  String get iataCode;
  @override
  String get cityName;
  @override
  String get country;
  @override
  WeatherCoordinates get coordinates;
  @override
  int get timezone;
  @override
  WeatherCurrent get current;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherStateImplCopyWith<_$WeatherStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherCoordinates _$WeatherCoordinatesFromJson(Map<String, dynamic> json) {
  return _WeatherCoordinates.fromJson(json);
}

/// @nodoc
mixin _$WeatherCoordinates {
  double get lat => throw _privateConstructorUsedError;
  double get lon => throw _privateConstructorUsedError;

  /// Serializes this WeatherCoordinates to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherCoordinates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCoordinatesCopyWith<WeatherCoordinates> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCoordinatesCopyWith<$Res> {
  factory $WeatherCoordinatesCopyWith(
    WeatherCoordinates value,
    $Res Function(WeatherCoordinates) then,
  ) = _$WeatherCoordinatesCopyWithImpl<$Res, WeatherCoordinates>;
  @useResult
  $Res call({double lat, double lon});
}

/// @nodoc
class _$WeatherCoordinatesCopyWithImpl<$Res, $Val extends WeatherCoordinates>
    implements $WeatherCoordinatesCopyWith<$Res> {
  _$WeatherCoordinatesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherCoordinates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lon = null}) {
    return _then(
      _value.copyWith(
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lon: null == lon
                ? _value.lon
                : lon // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherCoordinatesImplCopyWith<$Res>
    implements $WeatherCoordinatesCopyWith<$Res> {
  factory _$$WeatherCoordinatesImplCopyWith(
    _$WeatherCoordinatesImpl value,
    $Res Function(_$WeatherCoordinatesImpl) then,
  ) = __$$WeatherCoordinatesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lon});
}

/// @nodoc
class __$$WeatherCoordinatesImplCopyWithImpl<$Res>
    extends _$WeatherCoordinatesCopyWithImpl<$Res, _$WeatherCoordinatesImpl>
    implements _$$WeatherCoordinatesImplCopyWith<$Res> {
  __$$WeatherCoordinatesImplCopyWithImpl(
    _$WeatherCoordinatesImpl _value,
    $Res Function(_$WeatherCoordinatesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherCoordinates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lon = null}) {
    return _then(
      _$WeatherCoordinatesImpl(
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lon: null == lon
            ? _value.lon
            : lon // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherCoordinatesImpl implements _WeatherCoordinates {
  const _$WeatherCoordinatesImpl({required this.lat, required this.lon});

  factory _$WeatherCoordinatesImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherCoordinatesImplFromJson(json);

  @override
  final double lat;
  @override
  final double lon;

  @override
  String toString() {
    return 'WeatherCoordinates(lat: $lat, lon: $lon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherCoordinatesImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lon);

  /// Create a copy of WeatherCoordinates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherCoordinatesImplCopyWith<_$WeatherCoordinatesImpl> get copyWith =>
      __$$WeatherCoordinatesImplCopyWithImpl<_$WeatherCoordinatesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherCoordinatesImplToJson(this);
  }
}

abstract class _WeatherCoordinates implements WeatherCoordinates {
  const factory _WeatherCoordinates({
    required final double lat,
    required final double lon,
  }) = _$WeatherCoordinatesImpl;

  factory _WeatherCoordinates.fromJson(Map<String, dynamic> json) =
      _$WeatherCoordinatesImpl.fromJson;

  @override
  double get lat;
  @override
  double get lon;

  /// Create a copy of WeatherCoordinates
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherCoordinatesImplCopyWith<_$WeatherCoordinatesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherCurrent _$WeatherCurrentFromJson(Map<String, dynamic> json) {
  return _WeatherCurrent.fromJson(json);
}

/// @nodoc
mixin _$WeatherCurrent {
  double get temperature => throw _privateConstructorUsedError;
  double get feels_like => throw _privateConstructorUsedError;
  int get humidity => throw _privateConstructorUsedError;
  int get pressure => throw _privateConstructorUsedError;
  double get wind_speed => throw _privateConstructorUsedError;
  int get wind_direction => throw _privateConstructorUsedError;
  int get visibility => throw _privateConstructorUsedError;
  String get weather_condition => throw _privateConstructorUsedError;
  String get weather_description => throw _privateConstructorUsedError;
  String get weather_icon => throw _privateConstructorUsedError;
  int get uv_index => throw _privateConstructorUsedError;
  int get cloudiness => throw _privateConstructorUsedError;
  String get sunrise => throw _privateConstructorUsedError;
  String get sunset => throw _privateConstructorUsedError;

  /// Serializes this WeatherCurrent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCurrentCopyWith<WeatherCurrent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCurrentCopyWith<$Res> {
  factory $WeatherCurrentCopyWith(
    WeatherCurrent value,
    $Res Function(WeatherCurrent) then,
  ) = _$WeatherCurrentCopyWithImpl<$Res, WeatherCurrent>;
  @useResult
  $Res call({
    double temperature,
    double feels_like,
    int humidity,
    int pressure,
    double wind_speed,
    int wind_direction,
    int visibility,
    String weather_condition,
    String weather_description,
    String weather_icon,
    int uv_index,
    int cloudiness,
    String sunrise,
    String sunset,
  });
}

/// @nodoc
class _$WeatherCurrentCopyWithImpl<$Res, $Val extends WeatherCurrent>
    implements $WeatherCurrentCopyWith<$Res> {
  _$WeatherCurrentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? feels_like = null,
    Object? humidity = null,
    Object? pressure = null,
    Object? wind_speed = null,
    Object? wind_direction = null,
    Object? visibility = null,
    Object? weather_condition = null,
    Object? weather_description = null,
    Object? weather_icon = null,
    Object? uv_index = null,
    Object? cloudiness = null,
    Object? sunrise = null,
    Object? sunset = null,
  }) {
    return _then(
      _value.copyWith(
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            feels_like: null == feels_like
                ? _value.feels_like
                : feels_like // ignore: cast_nullable_to_non_nullable
                      as double,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as int,
            pressure: null == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as int,
            wind_speed: null == wind_speed
                ? _value.wind_speed
                : wind_speed // ignore: cast_nullable_to_non_nullable
                      as double,
            wind_direction: null == wind_direction
                ? _value.wind_direction
                : wind_direction // ignore: cast_nullable_to_non_nullable
                      as int,
            visibility: null == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as int,
            weather_condition: null == weather_condition
                ? _value.weather_condition
                : weather_condition // ignore: cast_nullable_to_non_nullable
                      as String,
            weather_description: null == weather_description
                ? _value.weather_description
                : weather_description // ignore: cast_nullable_to_non_nullable
                      as String,
            weather_icon: null == weather_icon
                ? _value.weather_icon
                : weather_icon // ignore: cast_nullable_to_non_nullable
                      as String,
            uv_index: null == uv_index
                ? _value.uv_index
                : uv_index // ignore: cast_nullable_to_non_nullable
                      as int,
            cloudiness: null == cloudiness
                ? _value.cloudiness
                : cloudiness // ignore: cast_nullable_to_non_nullable
                      as int,
            sunrise: null == sunrise
                ? _value.sunrise
                : sunrise // ignore: cast_nullable_to_non_nullable
                      as String,
            sunset: null == sunset
                ? _value.sunset
                : sunset // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherCurrentImplCopyWith<$Res>
    implements $WeatherCurrentCopyWith<$Res> {
  factory _$$WeatherCurrentImplCopyWith(
    _$WeatherCurrentImpl value,
    $Res Function(_$WeatherCurrentImpl) then,
  ) = __$$WeatherCurrentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double temperature,
    double feels_like,
    int humidity,
    int pressure,
    double wind_speed,
    int wind_direction,
    int visibility,
    String weather_condition,
    String weather_description,
    String weather_icon,
    int uv_index,
    int cloudiness,
    String sunrise,
    String sunset,
  });
}

/// @nodoc
class __$$WeatherCurrentImplCopyWithImpl<$Res>
    extends _$WeatherCurrentCopyWithImpl<$Res, _$WeatherCurrentImpl>
    implements _$$WeatherCurrentImplCopyWith<$Res> {
  __$$WeatherCurrentImplCopyWithImpl(
    _$WeatherCurrentImpl _value,
    $Res Function(_$WeatherCurrentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? feels_like = null,
    Object? humidity = null,
    Object? pressure = null,
    Object? wind_speed = null,
    Object? wind_direction = null,
    Object? visibility = null,
    Object? weather_condition = null,
    Object? weather_description = null,
    Object? weather_icon = null,
    Object? uv_index = null,
    Object? cloudiness = null,
    Object? sunrise = null,
    Object? sunset = null,
  }) {
    return _then(
      _$WeatherCurrentImpl(
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        feels_like: null == feels_like
            ? _value.feels_like
            : feels_like // ignore: cast_nullable_to_non_nullable
                  as double,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as int,
        pressure: null == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as int,
        wind_speed: null == wind_speed
            ? _value.wind_speed
            : wind_speed // ignore: cast_nullable_to_non_nullable
                  as double,
        wind_direction: null == wind_direction
            ? _value.wind_direction
            : wind_direction // ignore: cast_nullable_to_non_nullable
                  as int,
        visibility: null == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as int,
        weather_condition: null == weather_condition
            ? _value.weather_condition
            : weather_condition // ignore: cast_nullable_to_non_nullable
                  as String,
        weather_description: null == weather_description
            ? _value.weather_description
            : weather_description // ignore: cast_nullable_to_non_nullable
                  as String,
        weather_icon: null == weather_icon
            ? _value.weather_icon
            : weather_icon // ignore: cast_nullable_to_non_nullable
                  as String,
        uv_index: null == uv_index
            ? _value.uv_index
            : uv_index // ignore: cast_nullable_to_non_nullable
                  as int,
        cloudiness: null == cloudiness
            ? _value.cloudiness
            : cloudiness // ignore: cast_nullable_to_non_nullable
                  as int,
        sunrise: null == sunrise
            ? _value.sunrise
            : sunrise // ignore: cast_nullable_to_non_nullable
                  as String,
        sunset: null == sunset
            ? _value.sunset
            : sunset // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherCurrentImpl implements _WeatherCurrent {
  const _$WeatherCurrentImpl({
    required this.temperature,
    required this.feels_like,
    required this.humidity,
    required this.pressure,
    required this.wind_speed,
    required this.wind_direction,
    required this.visibility,
    required this.weather_condition,
    required this.weather_description,
    required this.weather_icon,
    required this.uv_index,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
  });

  factory _$WeatherCurrentImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherCurrentImplFromJson(json);

  @override
  final double temperature;
  @override
  final double feels_like;
  @override
  final int humidity;
  @override
  final int pressure;
  @override
  final double wind_speed;
  @override
  final int wind_direction;
  @override
  final int visibility;
  @override
  final String weather_condition;
  @override
  final String weather_description;
  @override
  final String weather_icon;
  @override
  final int uv_index;
  @override
  final int cloudiness;
  @override
  final String sunrise;
  @override
  final String sunset;

  @override
  String toString() {
    return 'WeatherCurrent(temperature: $temperature, feels_like: $feels_like, humidity: $humidity, pressure: $pressure, wind_speed: $wind_speed, wind_direction: $wind_direction, visibility: $visibility, weather_condition: $weather_condition, weather_description: $weather_description, weather_icon: $weather_icon, uv_index: $uv_index, cloudiness: $cloudiness, sunrise: $sunrise, sunset: $sunset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherCurrentImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.feels_like, feels_like) ||
                other.feels_like == feels_like) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure) &&
            (identical(other.wind_speed, wind_speed) ||
                other.wind_speed == wind_speed) &&
            (identical(other.wind_direction, wind_direction) ||
                other.wind_direction == wind_direction) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.weather_condition, weather_condition) ||
                other.weather_condition == weather_condition) &&
            (identical(other.weather_description, weather_description) ||
                other.weather_description == weather_description) &&
            (identical(other.weather_icon, weather_icon) ||
                other.weather_icon == weather_icon) &&
            (identical(other.uv_index, uv_index) ||
                other.uv_index == uv_index) &&
            (identical(other.cloudiness, cloudiness) ||
                other.cloudiness == cloudiness) &&
            (identical(other.sunrise, sunrise) || other.sunrise == sunrise) &&
            (identical(other.sunset, sunset) || other.sunset == sunset));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    temperature,
    feels_like,
    humidity,
    pressure,
    wind_speed,
    wind_direction,
    visibility,
    weather_condition,
    weather_description,
    weather_icon,
    uv_index,
    cloudiness,
    sunrise,
    sunset,
  );

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherCurrentImplCopyWith<_$WeatherCurrentImpl> get copyWith =>
      __$$WeatherCurrentImplCopyWithImpl<_$WeatherCurrentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherCurrentImplToJson(this);
  }
}

abstract class _WeatherCurrent implements WeatherCurrent {
  const factory _WeatherCurrent({
    required final double temperature,
    required final double feels_like,
    required final int humidity,
    required final int pressure,
    required final double wind_speed,
    required final int wind_direction,
    required final int visibility,
    required final String weather_condition,
    required final String weather_description,
    required final String weather_icon,
    required final int uv_index,
    required final int cloudiness,
    required final String sunrise,
    required final String sunset,
  }) = _$WeatherCurrentImpl;

  factory _WeatherCurrent.fromJson(Map<String, dynamic> json) =
      _$WeatherCurrentImpl.fromJson;

  @override
  double get temperature;
  @override
  double get feels_like;
  @override
  int get humidity;
  @override
  int get pressure;
  @override
  double get wind_speed;
  @override
  int get wind_direction;
  @override
  int get visibility;
  @override
  String get weather_condition;
  @override
  String get weather_description;
  @override
  String get weather_icon;
  @override
  int get uv_index;
  @override
  int get cloudiness;
  @override
  String get sunrise;
  @override
  String get sunset;

  /// Create a copy of WeatherCurrent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherCurrentImplCopyWith<_$WeatherCurrentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WeatherRequest {
  List<String> get iataCodes => throw _privateConstructorUsedError;
  String get units => throw _privateConstructorUsedError;
  bool get includeForecast => throw _privateConstructorUsedError;

  /// Create a copy of WeatherRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherRequestCopyWith<WeatherRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherRequestCopyWith<$Res> {
  factory $WeatherRequestCopyWith(
    WeatherRequest value,
    $Res Function(WeatherRequest) then,
  ) = _$WeatherRequestCopyWithImpl<$Res, WeatherRequest>;
  @useResult
  $Res call({List<String> iataCodes, String units, bool includeForecast});
}

/// @nodoc
class _$WeatherRequestCopyWithImpl<$Res, $Val extends WeatherRequest>
    implements $WeatherRequestCopyWith<$Res> {
  _$WeatherRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCodes = null,
    Object? units = null,
    Object? includeForecast = null,
  }) {
    return _then(
      _value.copyWith(
            iataCodes: null == iataCodes
                ? _value.iataCodes
                : iataCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            units: null == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as String,
            includeForecast: null == includeForecast
                ? _value.includeForecast
                : includeForecast // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherRequestImplCopyWith<$Res>
    implements $WeatherRequestCopyWith<$Res> {
  factory _$$WeatherRequestImplCopyWith(
    _$WeatherRequestImpl value,
    $Res Function(_$WeatherRequestImpl) then,
  ) = __$$WeatherRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> iataCodes, String units, bool includeForecast});
}

/// @nodoc
class __$$WeatherRequestImplCopyWithImpl<$Res>
    extends _$WeatherRequestCopyWithImpl<$Res, _$WeatherRequestImpl>
    implements _$$WeatherRequestImplCopyWith<$Res> {
  __$$WeatherRequestImplCopyWithImpl(
    _$WeatherRequestImpl _value,
    $Res Function(_$WeatherRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCodes = null,
    Object? units = null,
    Object? includeForecast = null,
  }) {
    return _then(
      _$WeatherRequestImpl(
        iataCodes: null == iataCodes
            ? _value._iataCodes
            : iataCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        units: null == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as String,
        includeForecast: null == includeForecast
            ? _value.includeForecast
            : includeForecast // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$WeatherRequestImpl implements _WeatherRequest {
  const _$WeatherRequestImpl({
    required final List<String> iataCodes,
    this.units = 'metric',
    this.includeForecast = false,
  }) : _iataCodes = iataCodes;

  final List<String> _iataCodes;
  @override
  List<String> get iataCodes {
    if (_iataCodes is EqualUnmodifiableListView) return _iataCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_iataCodes);
  }

  @override
  @JsonKey()
  final String units;
  @override
  @JsonKey()
  final bool includeForecast;

  @override
  String toString() {
    return 'WeatherRequest(iataCodes: $iataCodes, units: $units, includeForecast: $includeForecast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherRequestImpl &&
            const DeepCollectionEquality().equals(
              other._iataCodes,
              _iataCodes,
            ) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.includeForecast, includeForecast) ||
                other.includeForecast == includeForecast));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_iataCodes),
    units,
    includeForecast,
  );

  /// Create a copy of WeatherRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherRequestImplCopyWith<_$WeatherRequestImpl> get copyWith =>
      __$$WeatherRequestImplCopyWithImpl<_$WeatherRequestImpl>(
        this,
        _$identity,
      );
}

abstract class _WeatherRequest implements WeatherRequest {
  const factory _WeatherRequest({
    required final List<String> iataCodes,
    final String units,
    final bool includeForecast,
  }) = _$WeatherRequestImpl;

  @override
  List<String> get iataCodes;
  @override
  String get units;
  @override
  bool get includeForecast;

  /// Create a copy of WeatherRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherRequestImplCopyWith<_$WeatherRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherResponse _$WeatherResponseFromJson(Map<String, dynamic> json) {
  return _WeatherResponse.fromJson(json);
}

/// @nodoc
mixin _$WeatherResponse {
  bool get success => throw _privateConstructorUsedError;
  WeatherData get data => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;
  WeatherRequestParams get requestParams => throw _privateConstructorUsedError;

  /// Serializes this WeatherResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherResponseCopyWith<WeatherResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherResponseCopyWith<$Res> {
  factory $WeatherResponseCopyWith(
    WeatherResponse value,
    $Res Function(WeatherResponse) then,
  ) = _$WeatherResponseCopyWithImpl<$Res, WeatherResponse>;
  @useResult
  $Res call({
    bool success,
    WeatherData data,
    String source,
    String timestamp,
    WeatherRequestParams requestParams,
  });

  $WeatherDataCopyWith<$Res> get data;
  $WeatherRequestParamsCopyWith<$Res> get requestParams;
}

/// @nodoc
class _$WeatherResponseCopyWithImpl<$Res, $Val extends WeatherResponse>
    implements $WeatherResponseCopyWith<$Res> {
  _$WeatherResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? source = null,
    Object? timestamp = null,
    Object? requestParams = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as WeatherData,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
            requestParams: null == requestParams
                ? _value.requestParams
                : requestParams // ignore: cast_nullable_to_non_nullable
                      as WeatherRequestParams,
          )
          as $Val,
    );
  }

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherDataCopyWith<$Res> get data {
    return $WeatherDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherRequestParamsCopyWith<$Res> get requestParams {
    return $WeatherRequestParamsCopyWith<$Res>(_value.requestParams, (value) {
      return _then(_value.copyWith(requestParams: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherResponseImplCopyWith<$Res>
    implements $WeatherResponseCopyWith<$Res> {
  factory _$$WeatherResponseImplCopyWith(
    _$WeatherResponseImpl value,
    $Res Function(_$WeatherResponseImpl) then,
  ) = __$$WeatherResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    WeatherData data,
    String source,
    String timestamp,
    WeatherRequestParams requestParams,
  });

  @override
  $WeatherDataCopyWith<$Res> get data;
  @override
  $WeatherRequestParamsCopyWith<$Res> get requestParams;
}

/// @nodoc
class __$$WeatherResponseImplCopyWithImpl<$Res>
    extends _$WeatherResponseCopyWithImpl<$Res, _$WeatherResponseImpl>
    implements _$$WeatherResponseImplCopyWith<$Res> {
  __$$WeatherResponseImplCopyWithImpl(
    _$WeatherResponseImpl _value,
    $Res Function(_$WeatherResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = null,
    Object? source = null,
    Object? timestamp = null,
    Object? requestParams = null,
  }) {
    return _then(
      _$WeatherResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as WeatherData,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
        requestParams: null == requestParams
            ? _value.requestParams
            : requestParams // ignore: cast_nullable_to_non_nullable
                  as WeatherRequestParams,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherResponseImpl implements _WeatherResponse {
  const _$WeatherResponseImpl({
    required this.success,
    required this.data,
    required this.source,
    required this.timestamp,
    required this.requestParams,
  });

  factory _$WeatherResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final WeatherData data;
  @override
  final String source;
  @override
  final String timestamp;
  @override
  final WeatherRequestParams requestParams;

  @override
  String toString() {
    return 'WeatherResponse(success: $success, data: $data, source: $source, timestamp: $timestamp, requestParams: $requestParams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.requestParams, requestParams) ||
                other.requestParams == requestParams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, data, source, timestamp, requestParams);

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherResponseImplCopyWith<_$WeatherResponseImpl> get copyWith =>
      __$$WeatherResponseImplCopyWithImpl<_$WeatherResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherResponseImplToJson(this);
  }
}

abstract class _WeatherResponse implements WeatherResponse {
  const factory _WeatherResponse({
    required final bool success,
    required final WeatherData data,
    required final String source,
    required final String timestamp,
    required final WeatherRequestParams requestParams,
  }) = _$WeatherResponseImpl;

  factory _WeatherResponse.fromJson(Map<String, dynamic> json) =
      _$WeatherResponseImpl.fromJson;

  @override
  bool get success;
  @override
  WeatherData get data;
  @override
  String get source;
  @override
  String get timestamp;
  @override
  WeatherRequestParams get requestParams;

  /// Create a copy of WeatherResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherResponseImplCopyWith<_$WeatherResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) {
  return _WeatherData.fromJson(json);
}

/// @nodoc
mixin _$WeatherData {
  List<WeatherState> get cities => throw _privateConstructorUsedError;
  WeatherSummary get summary => throw _privateConstructorUsedError;

  /// Serializes this WeatherData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherDataCopyWith<WeatherData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherDataCopyWith<$Res> {
  factory $WeatherDataCopyWith(
    WeatherData value,
    $Res Function(WeatherData) then,
  ) = _$WeatherDataCopyWithImpl<$Res, WeatherData>;
  @useResult
  $Res call({List<WeatherState> cities, WeatherSummary summary});

  $WeatherSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$WeatherDataCopyWithImpl<$Res, $Val extends WeatherData>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cities = null, Object? summary = null}) {
    return _then(
      _value.copyWith(
            cities: null == cities
                ? _value.cities
                : cities // ignore: cast_nullable_to_non_nullable
                      as List<WeatherState>,
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as WeatherSummary,
          )
          as $Val,
    );
  }

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherSummaryCopyWith<$Res> get summary {
    return $WeatherSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeatherDataImplCopyWith<$Res>
    implements $WeatherDataCopyWith<$Res> {
  factory _$$WeatherDataImplCopyWith(
    _$WeatherDataImpl value,
    $Res Function(_$WeatherDataImpl) then,
  ) = __$$WeatherDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<WeatherState> cities, WeatherSummary summary});

  @override
  $WeatherSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$WeatherDataImplCopyWithImpl<$Res>
    extends _$WeatherDataCopyWithImpl<$Res, _$WeatherDataImpl>
    implements _$$WeatherDataImplCopyWith<$Res> {
  __$$WeatherDataImplCopyWithImpl(
    _$WeatherDataImpl _value,
    $Res Function(_$WeatherDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cities = null, Object? summary = null}) {
    return _then(
      _$WeatherDataImpl(
        cities: null == cities
            ? _value._cities
            : cities // ignore: cast_nullable_to_non_nullable
                  as List<WeatherState>,
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as WeatherSummary,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherDataImpl implements _WeatherData {
  const _$WeatherDataImpl({
    required final List<WeatherState> cities,
    required this.summary,
  }) : _cities = cities;

  factory _$WeatherDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherDataImplFromJson(json);

  final List<WeatherState> _cities;
  @override
  List<WeatherState> get cities {
    if (_cities is EqualUnmodifiableListView) return _cities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cities);
  }

  @override
  final WeatherSummary summary;

  @override
  String toString() {
    return 'WeatherData(cities: $cities, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherDataImpl &&
            const DeepCollectionEquality().equals(other._cities, _cities) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cities),
    summary,
  );

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      __$$WeatherDataImplCopyWithImpl<_$WeatherDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherDataImplToJson(this);
  }
}

abstract class _WeatherData implements WeatherData {
  const factory _WeatherData({
    required final List<WeatherState> cities,
    required final WeatherSummary summary,
  }) = _$WeatherDataImpl;

  factory _WeatherData.fromJson(Map<String, dynamic> json) =
      _$WeatherDataImpl.fromJson;

  @override
  List<WeatherState> get cities;
  @override
  WeatherSummary get summary;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherSummary _$WeatherSummaryFromJson(Map<String, dynamic> json) {
  return _WeatherSummary.fromJson(json);
}

/// @nodoc
mixin _$WeatherSummary {
  int get totalCities => throw _privateConstructorUsedError;
  int get successfulRequests => throw _privateConstructorUsedError;
  int get failedRequests => throw _privateConstructorUsedError;
  String get cacheStatus => throw _privateConstructorUsedError;

  /// Serializes this WeatherSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherSummaryCopyWith<WeatherSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherSummaryCopyWith<$Res> {
  factory $WeatherSummaryCopyWith(
    WeatherSummary value,
    $Res Function(WeatherSummary) then,
  ) = _$WeatherSummaryCopyWithImpl<$Res, WeatherSummary>;
  @useResult
  $Res call({
    int totalCities,
    int successfulRequests,
    int failedRequests,
    String cacheStatus,
  });
}

/// @nodoc
class _$WeatherSummaryCopyWithImpl<$Res, $Val extends WeatherSummary>
    implements $WeatherSummaryCopyWith<$Res> {
  _$WeatherSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCities = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? cacheStatus = null,
  }) {
    return _then(
      _value.copyWith(
            totalCities: null == totalCities
                ? _value.totalCities
                : totalCities // ignore: cast_nullable_to_non_nullable
                      as int,
            successfulRequests: null == successfulRequests
                ? _value.successfulRequests
                : successfulRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            failedRequests: null == failedRequests
                ? _value.failedRequests
                : failedRequests // ignore: cast_nullable_to_non_nullable
                      as int,
            cacheStatus: null == cacheStatus
                ? _value.cacheStatus
                : cacheStatus // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherSummaryImplCopyWith<$Res>
    implements $WeatherSummaryCopyWith<$Res> {
  factory _$$WeatherSummaryImplCopyWith(
    _$WeatherSummaryImpl value,
    $Res Function(_$WeatherSummaryImpl) then,
  ) = __$$WeatherSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalCities,
    int successfulRequests,
    int failedRequests,
    String cacheStatus,
  });
}

/// @nodoc
class __$$WeatherSummaryImplCopyWithImpl<$Res>
    extends _$WeatherSummaryCopyWithImpl<$Res, _$WeatherSummaryImpl>
    implements _$$WeatherSummaryImplCopyWith<$Res> {
  __$$WeatherSummaryImplCopyWithImpl(
    _$WeatherSummaryImpl _value,
    $Res Function(_$WeatherSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCities = null,
    Object? successfulRequests = null,
    Object? failedRequests = null,
    Object? cacheStatus = null,
  }) {
    return _then(
      _$WeatherSummaryImpl(
        totalCities: null == totalCities
            ? _value.totalCities
            : totalCities // ignore: cast_nullable_to_non_nullable
                  as int,
        successfulRequests: null == successfulRequests
            ? _value.successfulRequests
            : successfulRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        failedRequests: null == failedRequests
            ? _value.failedRequests
            : failedRequests // ignore: cast_nullable_to_non_nullable
                  as int,
        cacheStatus: null == cacheStatus
            ? _value.cacheStatus
            : cacheStatus // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherSummaryImpl implements _WeatherSummary {
  const _$WeatherSummaryImpl({
    required this.totalCities,
    required this.successfulRequests,
    required this.failedRequests,
    required this.cacheStatus,
  });

  factory _$WeatherSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherSummaryImplFromJson(json);

  @override
  final int totalCities;
  @override
  final int successfulRequests;
  @override
  final int failedRequests;
  @override
  final String cacheStatus;

  @override
  String toString() {
    return 'WeatherSummary(totalCities: $totalCities, successfulRequests: $successfulRequests, failedRequests: $failedRequests, cacheStatus: $cacheStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherSummaryImpl &&
            (identical(other.totalCities, totalCities) ||
                other.totalCities == totalCities) &&
            (identical(other.successfulRequests, successfulRequests) ||
                other.successfulRequests == successfulRequests) &&
            (identical(other.failedRequests, failedRequests) ||
                other.failedRequests == failedRequests) &&
            (identical(other.cacheStatus, cacheStatus) ||
                other.cacheStatus == cacheStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalCities,
    successfulRequests,
    failedRequests,
    cacheStatus,
  );

  /// Create a copy of WeatherSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherSummaryImplCopyWith<_$WeatherSummaryImpl> get copyWith =>
      __$$WeatherSummaryImplCopyWithImpl<_$WeatherSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherSummaryImplToJson(this);
  }
}

abstract class _WeatherSummary implements WeatherSummary {
  const factory _WeatherSummary({
    required final int totalCities,
    required final int successfulRequests,
    required final int failedRequests,
    required final String cacheStatus,
  }) = _$WeatherSummaryImpl;

  factory _WeatherSummary.fromJson(Map<String, dynamic> json) =
      _$WeatherSummaryImpl.fromJson;

  @override
  int get totalCities;
  @override
  int get successfulRequests;
  @override
  int get failedRequests;
  @override
  String get cacheStatus;

  /// Create a copy of WeatherSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherSummaryImplCopyWith<_$WeatherSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherRequestParams _$WeatherRequestParamsFromJson(Map<String, dynamic> json) {
  return _WeatherRequestParams.fromJson(json);
}

/// @nodoc
mixin _$WeatherRequestParams {
  List<String> get iataCodes => throw _privateConstructorUsedError;
  String get units => throw _privateConstructorUsedError;
  bool get includeForecast => throw _privateConstructorUsedError;

  /// Serializes this WeatherRequestParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherRequestParamsCopyWith<WeatherRequestParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherRequestParamsCopyWith<$Res> {
  factory $WeatherRequestParamsCopyWith(
    WeatherRequestParams value,
    $Res Function(WeatherRequestParams) then,
  ) = _$WeatherRequestParamsCopyWithImpl<$Res, WeatherRequestParams>;
  @useResult
  $Res call({List<String> iataCodes, String units, bool includeForecast});
}

/// @nodoc
class _$WeatherRequestParamsCopyWithImpl<
  $Res,
  $Val extends WeatherRequestParams
>
    implements $WeatherRequestParamsCopyWith<$Res> {
  _$WeatherRequestParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCodes = null,
    Object? units = null,
    Object? includeForecast = null,
  }) {
    return _then(
      _value.copyWith(
            iataCodes: null == iataCodes
                ? _value.iataCodes
                : iataCodes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            units: null == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as String,
            includeForecast: null == includeForecast
                ? _value.includeForecast
                : includeForecast // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherRequestParamsImplCopyWith<$Res>
    implements $WeatherRequestParamsCopyWith<$Res> {
  factory _$$WeatherRequestParamsImplCopyWith(
    _$WeatherRequestParamsImpl value,
    $Res Function(_$WeatherRequestParamsImpl) then,
  ) = __$$WeatherRequestParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> iataCodes, String units, bool includeForecast});
}

/// @nodoc
class __$$WeatherRequestParamsImplCopyWithImpl<$Res>
    extends _$WeatherRequestParamsCopyWithImpl<$Res, _$WeatherRequestParamsImpl>
    implements _$$WeatherRequestParamsImplCopyWith<$Res> {
  __$$WeatherRequestParamsImplCopyWithImpl(
    _$WeatherRequestParamsImpl _value,
    $Res Function(_$WeatherRequestParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iataCodes = null,
    Object? units = null,
    Object? includeForecast = null,
  }) {
    return _then(
      _$WeatherRequestParamsImpl(
        iataCodes: null == iataCodes
            ? _value._iataCodes
            : iataCodes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        units: null == units
            ? _value.units
            : units // ignore: cast_nullable_to_non_nullable
                  as String,
        includeForecast: null == includeForecast
            ? _value.includeForecast
            : includeForecast // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherRequestParamsImpl implements _WeatherRequestParams {
  const _$WeatherRequestParamsImpl({
    required final List<String> iataCodes,
    required this.units,
    required this.includeForecast,
  }) : _iataCodes = iataCodes;

  factory _$WeatherRequestParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherRequestParamsImplFromJson(json);

  final List<String> _iataCodes;
  @override
  List<String> get iataCodes {
    if (_iataCodes is EqualUnmodifiableListView) return _iataCodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_iataCodes);
  }

  @override
  final String units;
  @override
  final bool includeForecast;

  @override
  String toString() {
    return 'WeatherRequestParams(iataCodes: $iataCodes, units: $units, includeForecast: $includeForecast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherRequestParamsImpl &&
            const DeepCollectionEquality().equals(
              other._iataCodes,
              _iataCodes,
            ) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.includeForecast, includeForecast) ||
                other.includeForecast == includeForecast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_iataCodes),
    units,
    includeForecast,
  );

  /// Create a copy of WeatherRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherRequestParamsImplCopyWith<_$WeatherRequestParamsImpl>
  get copyWith =>
      __$$WeatherRequestParamsImplCopyWithImpl<_$WeatherRequestParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherRequestParamsImplToJson(this);
  }
}

abstract class _WeatherRequestParams implements WeatherRequestParams {
  const factory _WeatherRequestParams({
    required final List<String> iataCodes,
    required final String units,
    required final bool includeForecast,
  }) = _$WeatherRequestParamsImpl;

  factory _WeatherRequestParams.fromJson(Map<String, dynamic> json) =
      _$WeatherRequestParamsImpl.fromJson;

  @override
  List<String> get iataCodes;
  @override
  String get units;
  @override
  bool get includeForecast;

  /// Create a copy of WeatherRequestParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherRequestParamsImplCopyWith<_$WeatherRequestParamsImpl>
  get copyWith => throw _privateConstructorUsedError;
}
