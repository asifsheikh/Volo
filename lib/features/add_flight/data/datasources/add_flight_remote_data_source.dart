import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../models/airport_model.dart';
import '../models/flight_model.dart';

abstract class AddFlightRemoteDataSource {
  Future<List<AirportModel>> getAirports();
  Future<List<FlightModel>> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required DateTime date,
  });
  Future<FlightModel> extractFlightFromTicket(String imagePath);
  Future<FlightModel> saveFlight(FlightModel flight);
}

class AddFlightRemoteDataSourceImpl implements AddFlightRemoteDataSource {
  final http.Client httpClient;
  final String baseUrl;

  AddFlightRemoteDataSourceImpl(this.httpClient, {this.baseUrl = 'https://searchflights-3ltmkayg6q-uc.a.run.app'});

  @override
  Future<List<AirportModel>> getAirports() async {
    try {
      // For now, load from local JSON file
      // In the future, this could be an API call
      final response = await httpClient.get(Uri.parse('$baseUrl/airports'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AirportModel.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load airports');
      }
    } catch (e) {
      throw Exception('Failed to load airports: $e');
    }
  }

  @override
  Future<List<FlightModel>> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required DateTime date,
  }) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/search').replace(queryParameters: {
          'from': departureIata,
          'to': arrivalIata,
          'date': date.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => FlightModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search flights');
      }
    } catch (e) {
      throw Exception('Failed to search flights: $e');
    }
  }

  @override
  Future<FlightModel> extractFlightFromTicket(String imagePath) async {
    try {
      // This would be implemented with AI/ML service
      // For now, return a mock flight
      return FlightModel(
        departureCity: 'New York',
        departureAirport: 'John F. Kennedy International Airport',
        departureIata: 'JFK',
        arrivalCity: 'London',
        arrivalAirport: 'Heathrow Airport',
        arrivalIata: 'LHR',
        departureDate: DateTime.now(), // Would be extracted from image
        arrivalDate: DateTime.now().add(const Duration(hours: 8)), // Would be extracted from image
        airline: 'British Airways',
        flightNumber: 'BA001',
      );
    } catch (e) {
      throw Exception('Failed to extract flight from ticket: $e');
    }
  }

  @override
  Future<FlightModel> saveFlight(FlightModel flight) async {
    try {
      // This would save to Firestore or local database
      // For now, just return the flight with an ID
      return FlightModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        departureCity: flight.departureCity,
        departureAirport: flight.departureAirport,
        departureIata: flight.departureIata,
        arrivalCity: flight.arrivalCity,
        arrivalAirport: flight.arrivalAirport,
        arrivalIata: flight.arrivalIata,
        departureDate: flight.departureDate,
        arrivalDate: flight.arrivalDate,
        airline: flight.airline,
        flightNumber: flight.flightNumber,
        gate: flight.gate,
        terminal: flight.terminal,
        status: flight.status,
      );
    } catch (e) {
      throw Exception('Failed to save flight: $e');
    }
  }
}

// Riverpod provider for the data source
final addFlightRemoteDataSourceProvider = Provider<AddFlightRemoteDataSource>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AddFlightRemoteDataSourceImpl(httpClient);
}); 