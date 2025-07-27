import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_results_state.dart' as domain;
import '../../domain/usecases/get_flight_results.dart';

part 'flight_results_provider.g.dart';

/// Provider for flight results state management
@riverpod
Future<domain.FlightResultsState> flightResultsProvider(FlightResultsProviderRef ref, {
  required String departureCity,
  required String arrivalCity,
  required String date,
  String? flightNumber,
}) async {
  return await ref.watch(getFlightResultsProvider(
    departureCity: departureCity,
    arrivalCity: arrivalCity,
    date: date,
    flightNumber: flightNumber,
  ).future);
} 