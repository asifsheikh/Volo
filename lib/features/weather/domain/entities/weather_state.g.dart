// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherStateImpl _$$WeatherStateImplFromJson(Map<String, dynamic> json) =>
    _$WeatherStateImpl(
      iataCode: json['iataCode'] as String,
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      coordinates: WeatherCoordinates.fromJson(
        json['coordinates'] as Map<String, dynamic>,
      ),
      timezone: (json['timezone'] as num).toInt(),
      current: WeatherCurrent.fromJson(json['current'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WeatherStateImplToJson(_$WeatherStateImpl instance) =>
    <String, dynamic>{
      'iataCode': instance.iataCode,
      'cityName': instance.cityName,
      'country': instance.country,
      'coordinates': instance.coordinates,
      'timezone': instance.timezone,
      'current': instance.current,
    };

_$WeatherCoordinatesImpl _$$WeatherCoordinatesImplFromJson(
  Map<String, dynamic> json,
) => _$WeatherCoordinatesImpl(
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
);

Map<String, dynamic> _$$WeatherCoordinatesImplToJson(
  _$WeatherCoordinatesImpl instance,
) => <String, dynamic>{'lat': instance.lat, 'lon': instance.lon};

_$WeatherCurrentImpl _$$WeatherCurrentImplFromJson(Map<String, dynamic> json) =>
    _$WeatherCurrentImpl(
      temperature: (json['temperature'] as num).toDouble(),
      feels_like: (json['feels_like'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      pressure: (json['pressure'] as num).toInt(),
      wind_speed: (json['wind_speed'] as num).toDouble(),
      wind_direction: (json['wind_direction'] as num).toInt(),
      visibility: (json['visibility'] as num).toInt(),
      weather_condition: json['weather_condition'] as String,
      weather_description: json['weather_description'] as String,
      weather_icon: json['weather_icon'] as String,
      weather_icon_info: WeatherIconInfo.fromJson(
        json['weather_icon_info'] as Map<String, dynamic>,
      ),
      uv_index: (json['uv_index'] as num).toInt(),
      cloudiness: (json['cloudiness'] as num).toInt(),
      sunrise: json['sunrise'] as String,
      sunset: json['sunset'] as String,
    );

Map<String, dynamic> _$$WeatherCurrentImplToJson(
  _$WeatherCurrentImpl instance,
) => <String, dynamic>{
  'temperature': instance.temperature,
  'feels_like': instance.feels_like,
  'humidity': instance.humidity,
  'pressure': instance.pressure,
  'wind_speed': instance.wind_speed,
  'wind_direction': instance.wind_direction,
  'visibility': instance.visibility,
  'weather_condition': instance.weather_condition,
  'weather_description': instance.weather_description,
  'weather_icon': instance.weather_icon,
  'weather_icon_info': instance.weather_icon_info,
  'uv_index': instance.uv_index,
  'cloudiness': instance.cloudiness,
  'sunrise': instance.sunrise,
  'sunset': instance.sunset,
};

_$WeatherIconInfoImpl _$$WeatherIconInfoImplFromJson(
  Map<String, dynamic> json,
) => _$WeatherIconInfoImpl(
  code: json['code'] as String,
  url: json['url'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  isDay: json['isDay'] as bool,
);

Map<String, dynamic> _$$WeatherIconInfoImplToJson(
  _$WeatherIconInfoImpl instance,
) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'description': instance.description,
  'category': instance.category,
  'isDay': instance.isDay,
};

_$WeatherResponseImpl _$$WeatherResponseImplFromJson(
  Map<String, dynamic> json,
) => _$WeatherResponseImpl(
  success: json['success'] as bool,
  data: WeatherData.fromJson(json['data'] as Map<String, dynamic>),
  source: json['source'] as String,
  timestamp: json['timestamp'] as String,
  requestParams: WeatherRequestParams.fromJson(
    json['requestParams'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$WeatherResponseImplToJson(
  _$WeatherResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'source': instance.source,
  'timestamp': instance.timestamp,
  'requestParams': instance.requestParams,
};

_$WeatherDataImpl _$$WeatherDataImplFromJson(Map<String, dynamic> json) =>
    _$WeatherDataImpl(
      cities: (json['cities'] as List<dynamic>)
          .map((e) => WeatherState.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: WeatherSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WeatherDataImplToJson(_$WeatherDataImpl instance) =>
    <String, dynamic>{'cities': instance.cities, 'summary': instance.summary};

_$WeatherSummaryImpl _$$WeatherSummaryImplFromJson(Map<String, dynamic> json) =>
    _$WeatherSummaryImpl(
      totalCities: (json['totalCities'] as num).toInt(),
      successfulRequests: (json['successfulRequests'] as num).toInt(),
      failedRequests: (json['failedRequests'] as num).toInt(),
      cacheStatus: json['cacheStatus'] as String,
    );

Map<String, dynamic> _$$WeatherSummaryImplToJson(
  _$WeatherSummaryImpl instance,
) => <String, dynamic>{
  'totalCities': instance.totalCities,
  'successfulRequests': instance.successfulRequests,
  'failedRequests': instance.failedRequests,
  'cacheStatus': instance.cacheStatus,
};

_$WeatherRequestParamsImpl _$$WeatherRequestParamsImplFromJson(
  Map<String, dynamic> json,
) => _$WeatherRequestParamsImpl(
  iataCodes: (json['iataCodes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  units: json['units'] as String,
  includeForecast: json['includeForecast'] as bool,
);

Map<String, dynamic> _$$WeatherRequestParamsImplToJson(
  _$WeatherRequestParamsImpl instance,
) => <String, dynamic>{
  'iataCodes': instance.iataCodes,
  'units': instance.units,
  'includeForecast': instance.includeForecast,
};
