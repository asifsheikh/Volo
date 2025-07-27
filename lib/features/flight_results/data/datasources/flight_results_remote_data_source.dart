import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/flight_results_state.dart' as domain;
import '../../../../services/flight_api_service.dart';
import '../../../../services/network_service.dart';

part 'flight_results_remote_data_source.g.dart';

/// Remote data source for flight results
@riverpod
class FlightResultsRemoteDataSource extends _$FlightResultsRemoteDataSource {
  @override
  Future<domain.FlightResultsState> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get flight results from the API
  Future<domain.FlightResultsState> getFlightResults({
    required String departureCity,
    required String arrivalCity,
    required String date,
    String? flightNumber,
  }) async {
    try {
      // Use the existing FlightApiService
      final searchResponse = await FlightApiService.searchFlights(
        departureIata: departureCity,
        arrivalIata: arrivalCity,
        date: date,
        flightNumber: flightNumber,
      );

      // Convert to our domain entities
      final bestFlights = searchResponse.bestFlights.map((flight) => 
        domain.FlightOption(
          flights: flight.flights.map((f) => domain.Flight(
            airline: f.airline,
            flightNumber: f.flightNumber,
            departureAirport: domain.AirportInfo(
              id: f.departureAirport.id,
              name: f.departureAirport.name,
              time: f.departureAirport.time,
              terminal: null, // Not available in existing model
            ),
            arrivalAirport: domain.AirportInfo(
              id: f.arrivalAirport.id,
              name: f.arrivalAirport.name,
              time: f.arrivalAirport.time,
              terminal: null, // Not available in existing model
            ),
            airplane: f.airplane,
            extensions: f.extensions,
          )).toList(),
          totalDuration: flight.totalDuration,
          price: flight.price,
          type: flight.type,
          airlineLogo: flight.airlineLogo,
          bookingToken: flight.bookingToken,
          carbonEmissions: flight.carbonEmissions != null ? domain.CarbonEmissions(
            kg: flight.carbonEmissions!.thisFlight,
            unit: 'kg',
          ) : null,
          layovers: flight.layovers,
        )
      ).toList();

      final otherFlights = searchResponse.otherFlights.map((flight) => 
        domain.FlightOption(
          flights: flight.flights.map((f) => domain.Flight(
            airline: f.airline,
            flightNumber: f.flightNumber,
            departureAirport: domain.AirportInfo(
              id: f.departureAirport.id,
              name: f.departureAirport.name,
              time: f.departureAirport.time,
              terminal: null, // Not available in existing model
            ),
            arrivalAirport: domain.AirportInfo(
              id: f.arrivalAirport.id,
              name: f.arrivalAirport.name,
              time: f.arrivalAirport.time,
              terminal: null, // Not available in existing model
            ),
            airplane: f.airplane,
            extensions: f.extensions,
          )).toList(),
          totalDuration: flight.totalDuration,
          price: flight.price,
          type: flight.type,
          airlineLogo: flight.airlineLogo,
          bookingToken: flight.bookingToken,
          carbonEmissions: flight.carbonEmissions != null ? domain.CarbonEmissions(
            kg: flight.carbonEmissions!.thisFlight,
            unit: 'kg',
          ) : null,
          layovers: flight.layovers,
        )
      ).toList();

      // Convert airports - the existing AirportInfo has a different structure
      final airports = <domain.AirportInfo>[];
      for (final airportInfo in searchResponse.airports) {
        // Add departure airports
        for (final departure in airportInfo.departure) {
          airports.add(domain.AirportInfo(
            id: departure.airport.id,
            name: departure.airport.name,
            time: departure.airport.time,
            terminal: null,
          ));
        }
        // Add arrival airports
        for (final arrival in airportInfo.arrival) {
          airports.add(domain.AirportInfo(
            id: arrival.airport.id,
            name: arrival.airport.name,
            time: arrival.airport.time,
            terminal: null,
          ));
        }
      }

      return domain.FlightResultsState(
        departureCity: departureCity,
        arrivalCity: arrivalCity,
        date: date,
        bestFlights: bestFlights,
        otherFlights: otherFlights,
        airports: airports,
      );
    } catch (e) {
      throw Exception('Failed to get flight results: $e');
    }
  }

  /// Check network connectivity
  Future<bool> hasInternetConnection() async {
    final networkService = NetworkService();
    return await networkService.isConnected();
  }
} 