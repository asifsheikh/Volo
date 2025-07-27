import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weather_state.dart' as domain;
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

part 'weather_repository_impl.g.dart';

/// Repository implementation for weather
@riverpod
class WeatherRepositoryImpl extends _$WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  @override
  Future<List<domain.WeatherState>> getWeatherData(List<String> iataCodes) async {
    final dataSource = ref.read(weatherRemoteDataSourceProvider.notifier);
    return await dataSource.getWeatherData(iataCodes);
  }

  @override
  Future<domain.WeatherState?> getWeatherForCity(String iataCode) async {
    final dataSource = ref.read(weatherRemoteDataSourceProvider.notifier);
    return await dataSource.getWeatherForCity(iataCode);
  }

  @override
  Future<bool> isWeatherCached(List<String> iataCodes) async {
    // For now, return false to always fetch fresh data
    // TODO: Implement proper caching with SharedPreferences or Hive
    return false;
  }

  @override
  Future<List<domain.WeatherState>?> getCachedWeatherData(List<String> iataCodes) async {
    // For now, return null to always fetch fresh data
    // TODO: Implement proper caching with SharedPreferences or Hive
    return null;
  }

  @override
  Future<void> cacheWeatherData(List<String> iataCodes, List<domain.WeatherState> weatherData) async {
    // For now, do nothing
    // TODO: Implement proper caching with SharedPreferences or Hive
  }
} 