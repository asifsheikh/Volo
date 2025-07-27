import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/flight_results_state.dart' as domain;
import '../repositories/flight_results_repository.dart';
import '../../data/repositories/flight_results_repository_impl.dart';

part 'get_flight_results.g.dart';

/// Use case for getting flight results
@riverpod
class GetFlightResults extends _$GetFlightResults {
  @override
  Future<domain.FlightResultsState> build({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    return _getFlightResults(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  Future<domain.FlightResultsState> _getFlightResults({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    try {
      final repository = ref.read(flightResultsRepositoryImplProvider.notifier);
      
      // Check network connectivity first
      final hasInternet = await repository.hasInternetConnection();
      
      if (!hasInternet) {
        return domain.FlightResultsState(
          departureCity: departureCity,
          arrivalCity: arrivalCity,
          date: date,
          bestFlights: [],
          otherFlights: [],
          airports: [],
          isOffline: true,
        );
      }

      // Get flight results
      final flightResults = await repository.getFlightResults(
        departureCity: departureCity,
        arrivalCity: arrivalCity,
        date: date,
        flightNumber: flightNumber,
      );
      
      return flightResults;
    } catch (e) {
      return domain.FlightResultsState(
        departureCity: departureCity,
        arrivalCity: arrivalCity,
        date: date,
        bestFlights: [],
        otherFlights: [],
        airports: [],
        isOffline: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh flight results
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getFlightResults(
      departureCity: state.value?.departureCity ?? '',
      arrivalCity: state.value?.arrivalCity ?? '',
      date: state.value?.date ?? '',
      flightNumber: null,
    ));
  }
} 