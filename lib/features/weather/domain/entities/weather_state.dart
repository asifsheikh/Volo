import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_state.freezed.dart';
part 'weather_state.g.dart';

@freezed
class WeatherState with _$WeatherState {
  const factory WeatherState({
    required String iataCode,
    required String cityName,
    required String country,
    required WeatherCoordinates coordinates,
    required int timezone,
    required WeatherCurrent current,
  }) = _WeatherState;

  factory WeatherState.fromJson(Map<String, dynamic> json) => _$WeatherStateFromJson(json);
}

@freezed
class WeatherCoordinates with _$WeatherCoordinates {
  const factory WeatherCoordinates({
    required double lat,
    required double lon,
  }) = _WeatherCoordinates;

  factory WeatherCoordinates.fromJson(Map<String, dynamic> json) => _$WeatherCoordinatesFromJson(json);
}

@freezed
class WeatherCurrent with _$WeatherCurrent {
  const factory WeatherCurrent({
    required double temperature,
    required double feels_like,
    required int humidity,
    required int pressure,
    required double wind_speed,
    required int wind_direction,
    required int visibility,
    required String weather_condition,
    required String weather_description,
    required String weather_icon,
    required WeatherIconInfo weather_icon_info,
    required int uv_index,
    required int cloudiness,
    required String sunrise,
    required String sunset,
  }) = _WeatherCurrent;

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) => _$WeatherCurrentFromJson(json);
}

@freezed
class WeatherIconInfo with _$WeatherIconInfo {
  const factory WeatherIconInfo({
    required String code,
    required String url,
    required String description,
    required String category,
    required bool isDay,
  }) = _WeatherIconInfo;

  factory WeatherIconInfo.fromJson(Map<String, dynamic> json) => _$WeatherIconInfoFromJson(json);
}

@freezed
class WeatherRequest with _$WeatherRequest {
  const factory WeatherRequest({
    required List<String> iataCodes,
    @Default('metric') String units,
    @Default(false) bool includeForecast,
  }) = _WeatherRequest;
}

@freezed
class WeatherResponse with _$WeatherResponse {
  const factory WeatherResponse({
    required bool success,
    required WeatherData data,
    required String source,
    required String timestamp,
    required WeatherRequestParams requestParams,
  }) = _WeatherResponse;

  factory WeatherResponse.fromJson(Map<String, dynamic> json) => _$WeatherResponseFromJson(json);
}

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    required List<WeatherState> cities,
    required WeatherSummary summary,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
}

@freezed
class WeatherSummary with _$WeatherSummary {
  const factory WeatherSummary({
    required int totalCities,
    required int successfulRequests,
    required int failedRequests,
    required String cacheStatus,
  }) = _WeatherSummary;

  factory WeatherSummary.fromJson(Map<String, dynamic> json) => _$WeatherSummaryFromJson(json);
}

@freezed
class WeatherRequestParams with _$WeatherRequestParams {
  const factory WeatherRequestParams({
    required List<String> iataCodes,
    required String units,
    required bool includeForecast,
  }) = _WeatherRequestParams;

  factory WeatherRequestParams.fromJson(Map<String, dynamic> json) => _$WeatherRequestParamsFromJson(json);
} 