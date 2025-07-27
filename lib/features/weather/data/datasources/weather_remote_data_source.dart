import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_state.dart' as domain;

part 'weather_remote_data_source.g.dart';

/// Remote data source for weather API
@riverpod
class WeatherRemoteDataSource extends _$WeatherRemoteDataSource {
  static const String _baseUrl = 'https://us-central1-volo-app-1.cloudfunctions.net';
  static const String _weatherEndpoint = '/getWeatherMulti';

  @override
  Future<List<domain.WeatherState>> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get weather data for multiple cities
  Future<List<domain.WeatherState>> getWeatherData(List<String> iataCodes) async {
    try {
      final uri = Uri.parse('$_baseUrl$_weatherEndpoint').replace(
        queryParameters: {
          'iataCodes': iataCodes.join(','),
          'units': 'metric',
          'includeForecast': 'false',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final weatherResponse = domain.WeatherResponse.fromJson(jsonData);

        if (weatherResponse.success) {
          return weatherResponse.data.cities;
        } else {
          throw Exception('Weather API returned success: false');
        }
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Weather data error: $e');
    }
  }

  /// Get weather data for a single city
  Future<domain.WeatherState?> getWeatherForCity(String iataCode) async {
    try {
      final weatherData = await getWeatherData([iataCode]);
      return weatherData.isNotEmpty ? weatherData.first : null;
    } catch (e) {
      throw Exception('Failed to get weather for city $iataCode: $e');
    }
  }
} 