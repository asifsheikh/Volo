import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_select_state.dart' as domain;
import '../../domain/usecases/get_flight_select_data.dart';

part 'flight_select_provider.g.dart';

/// Provider for flight select state management
@riverpod
Future<domain.FlightSelectState> flightSelectProvider(FlightSelectProviderRef ref, {
  required String departureCity,
  required String arrivalCity,
  required String date,
  String? flightNumber,
}) async {
  return await ref.watch(getFlightSelectDataProvider(
    departureCity: departureCity,
    arrivalCity: arrivalCity,
    date: date,
    flightNumber: flightNumber,
  ).future);
} 