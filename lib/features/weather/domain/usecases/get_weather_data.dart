import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/weather_state.dart' as domain;
import '../repositories/weather_repository.dart';
import '../../data/repositories/weather_repository_impl.dart';

part 'get_weather_data.g.dart';

/// Use case for getting weather data
@riverpod
class GetWeatherData extends _$GetWeatherData {
  @override
  Future<List<domain.WeatherState>> build(List<String> iataCodes) async {
    return _getWeatherData(iataCodes);
  }

  Future<List<domain.WeatherState>> _getWeatherData(List<String> iataCodes) async {
    try {
      final repository = ref.read(weatherRepositoryImplProvider.notifier);
      
      // Check cache first
      final isCached = await repository.isWeatherCached(iataCodes);
      if (isCached) {
        final cachedData = await repository.getCachedWeatherData(iataCodes);
        if (cachedData != null && cachedData.isNotEmpty) {
          return cachedData;
        }
      }
      
      // Fetch fresh data from API
      final weatherData = await repository.getWeatherData(iataCodes);
      
      // Cache the fresh data
      await repository.cacheWeatherData(iataCodes, weatherData);
      
      return weatherData;
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  /// Refresh weather data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getWeatherData(state.value?.map((w) => w.iataCode).toList() ?? []));
  }
} 