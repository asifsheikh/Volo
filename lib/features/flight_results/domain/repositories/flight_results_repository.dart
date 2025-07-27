import '../entities/flight_results_state.dart';

abstract class FlightResultsRepository {
  /// Get flight results for the given search criteria
  Future<FlightResultsState> getFlightResults({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  });

  /// Check if device has internet connection
  Future<bool> hasInternetConnection();
} 