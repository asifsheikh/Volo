import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weather_state.dart' as domain;
import '../../data/repositories/weather_repository_impl.dart';

part 'weather_provider.g.dart';

/// Global weather provider that manages all weather data
@riverpod
class GlobalWeatherNotifier extends _$GlobalWeatherNotifier {
  @override
  Map<String, domain.WeatherState> build() {
    return {};
  }

  /// Get weather data for specific IATA codes
  Future<void> loadWeatherData(List<String> iataCodes) async {
    print('Weather Provider Debug: Loading weather for IATA codes = $iataCodes');
    
    // Check if we already have data for these codes
    final missingCodes = iataCodes.where((code) => !state.containsKey(code)).toList();
    if (missingCodes.isEmpty) {
      print('Weather Provider Debug: All weather data already cached');
      return;
    }

    try {
      final repository = ref.read(weatherRepositoryImplProvider.notifier);
      final result = await repository.getWeatherData(missingCodes);
      
      // Update state with new weather data
      final newState = Map<String, domain.WeatherState>.from(state);
      for (final weather in result) {
        newState[weather.iataCode] = weather;
      }
      
      state = newState;
      print('Weather Provider Debug: Loaded ${result.length} weather states');
    } catch (e) {
      print('Weather Provider Debug: Error loading weather data = $e');
    }
  }

  /// Get weather for a specific IATA code
  domain.WeatherState? getWeatherForCode(String iataCode) {
    return state[iataCode];
  }
}

/// Legacy provider for backward compatibility
@riverpod
Future<List<domain.WeatherState>> weatherNotifier(
  WeatherNotifierRef ref,
  List<String> iataCodes,
) async {
  final globalWeather = ref.read(globalWeatherNotifierProvider.notifier);
  await globalWeather.loadWeatherData(iataCodes);
  
  return iataCodes
      .map((code) => globalWeather.getWeatherForCode(code))
      .where((weather) => weather != null)
      .cast<domain.WeatherState>()
      .toList();
} 