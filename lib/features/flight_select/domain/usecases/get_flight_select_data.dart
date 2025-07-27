import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/flight_select_state.dart' as domain;
import '../repositories/flight_select_repository.dart';
import '../../data/repositories/flight_select_repository_impl.dart';

part 'get_flight_select_data.g.dart';

/// Use case for getting flight select data
@riverpod
class GetFlightSelectData extends _$GetFlightSelectData {
  @override
  Future<domain.FlightSelectState> build({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    return _getFlightSelectData(
      departureCity: departureCity,
      arrivalCity: arrivalCity,
      date: date,
      flightNumber: flightNumber,
    );
  }

  Future<domain.FlightSelectState> _getFlightSelectData({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    try {
      final repository = ref.read(flightSelectRepositoryImplProvider.notifier);
      
      // Check network connectivity first
      final hasInternet = await repository.hasInternetConnection();
      
      if (!hasInternet) {
        return domain.FlightSelectState(
          departureCity: departureCity,
          arrivalCity: arrivalCity,
          date: date,
          bestFlights: [],
          otherFlights: [],
          airports: [],
          isOffline: true,
        );
      }

      // Get flight select data
      final flightSelectData = await repository.getFlightSelectData(
        departureCity: departureCity,
        arrivalCity: arrivalCity,
        date: date,
        flightNumber: flightNumber,
      );
      
      return flightSelectData;
    } catch (e) {
      return domain.FlightSelectState(
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

  /// Refresh flight select data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _getFlightSelectData(
      departureCity: state.value?.departureCity ?? '',
      arrivalCity: state.value?.arrivalCity ?? '',
      date: state.value?.date ?? '',
      flightNumber: null,
    ));
  }
} 