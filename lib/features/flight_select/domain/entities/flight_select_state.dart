import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_select_state.freezed.dart';

@freezed
class FlightSelectState with _$FlightSelectState {
  const factory FlightSelectState({
    required String departureCity,
    required String arrivalCity,
    required String date,
    required List<FlightOption> bestFlights,
    required List<FlightOption> otherFlights,
    required List<AirportInfo> airports,
    @Default(false) bool isLoading,
    @Default(false) bool isOffline,
    String? errorMessage,
    int? expandedIndex,
  }) = _FlightSelectState;
}

@freezed
class FlightOption with _$FlightOption {
  const factory FlightOption({
    required List<Flight> flights,
    required int totalDuration,
    required int price,
    required String type,
    String? airlineLogo,
    String? bookingToken,
    CarbonEmissions? carbonEmissions,
    List<Map<String, dynamic>>? layovers,
  }) = _FlightOption;
}

@freezed
class Flight with _$Flight {
  const factory Flight({
    required String airline,
    required String flightNumber,
    required AirportInfo departureAirport,
    required AirportInfo arrivalAirport,
    String? airplane,
    List<String>? extensions,
  }) = _Flight;
}

@freezed
class AirportInfo with _$AirportInfo {
  const factory AirportInfo({
    required String id,
    required String name,
    required String time,
    String? terminal,
  }) = _AirportInfo;
}

@freezed
class CarbonEmissions with _$CarbonEmissions {
  const factory CarbonEmissions({
    required int kg,
    required String unit,
  }) = _CarbonEmissions;
} 