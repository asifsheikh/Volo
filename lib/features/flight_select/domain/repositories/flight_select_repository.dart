import '../entities/flight_select_state.dart';

abstract class FlightSelectRepository {
  /// Get flight select data for the given search criteria
  Future<FlightSelectState> getFlightSelectData({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  });

  /// Check if device has internet connection
  Future<bool> hasInternetConnection();
} 