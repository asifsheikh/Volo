import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weather_state.dart' as domain;
import '../../domain/usecases/get_weather_data.dart';

part 'weather_provider.g.dart';

/// Provider for weather state management
@riverpod
Future<List<domain.WeatherState>> weatherProvider(
  WeatherProviderRef ref,
  List<String> iataCodes,
) async {
  print('Weather Provider Debug: Called with IATA codes = $iataCodes');
  final result = await ref.watch(getWeatherDataProvider(iataCodes).future);
  print('Weather Provider Debug: Returning ${result.length} weather states');
  return result;
} 