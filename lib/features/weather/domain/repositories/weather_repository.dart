import '../entities/weather_state.dart';

abstract class WeatherRepository {
  /// Get weather data for multiple cities by IATA codes
  Future<List<WeatherState>> getWeatherData(List<String> iataCodes);
  
  /// Get weather data for a single city by IATA code
  Future<WeatherState?> getWeatherForCity(String iataCode);
  
  /// Check if weather data is cached
  Future<bool> isWeatherCached(List<String> iataCodes);
  
  /// Get cached weather data
  Future<List<WeatherState>?> getCachedWeatherData(List<String> iataCodes);
  
  /// Cache weather data
  Future<void> cacheWeatherData(List<String> iataCodes, List<WeatherState> weatherData);
} 