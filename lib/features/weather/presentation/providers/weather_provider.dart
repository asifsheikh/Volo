import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weather_state.dart' as domain;
import '../../data/repositories/weather_repository_impl.dart';

part 'weather_provider.g.dart';

/// Provider for weather state management
@riverpod
class WeatherNotifier extends _$WeatherNotifier {
  @override
  Future<List<domain.WeatherState>> build(List<String> iataCodes) async {
    print('Weather Provider Debug: Called with IATA codes = $iataCodes');
    final repository = ref.read(weatherRepositoryImplProvider.notifier);
    final result = await repository.getWeatherData(iataCodes);
    print('Weather Provider Debug: Returning ${result.length} weather states');
    return result;
  }
}

/// Legacy provider for backward compatibility
@riverpod
Future<List<domain.WeatherState>> weatherProvider(
  WeatherProviderRef ref,
  List<String> iataCodes,
) async {
  return ref.watch(weatherNotifierProvider(iataCodes).future);
} 