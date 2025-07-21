import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'network_service.dart';

class FlightApiService {
  static const String _baseUrl = 'https://searchflights-3ltmkayg6q-uc.a.run.app';
  


  /// Search for flights using the production backend API
  static Future<FlightSearchResponse> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required String date,
    String? flightNumber,
  }) async {
    developer.log('Searching flights: $departureIata → $arrivalIata on $date', name: 'VoloFlightAPI');
    
    try {
      developer.log('🟢 Using PRODUCTION flight API', name: 'VoloFlightAPI');
      
      final queryParameters = {
        'departureIata': departureIata,
        'arrivalIata': arrivalIata,
        'date': date,
        if (flightNumber != null && flightNumber.isNotEmpty) 'flightNumber': flightNumber,
      };
      
      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
      developer.log('🟢 API URL: $uri', name: 'VoloFlightAPI');

      // Use NetworkService for better error handling
      final networkService = NetworkService();
      final response = await networkService.makeRequest(
        () => http.get(uri),
        timeout: const Duration(seconds: 30),
      );
      
      developer.log('🟢 API Response Status: ${response.statusCode}', name: 'VoloFlightAPI');
      
      // Check for HTTP errors
      final httpError = networkService.handleHttpResponse(response);
      if (httpError != null) {
        throw httpError;
      }
      
      final data = json.decode(response.body);
      developer.log('🟢 API Response received successfully', name: 'VoloFlightAPI');
      
      if (data['success'] != true) {
        developer.log('❌ API Error: ${data['error'] ?? 'Unknown error'}', name: 'VoloFlightAPI');
        throw NetworkError(
          type: NetworkErrorType.serverError,
          message: 'API Error: ${data['error'] ?? 'Unknown error'}',
        );
      }
      
      // Extract data from the new response format
      final responseData = data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        throw NetworkError(
          type: NetworkErrorType.serverError,
          message: 'Invalid response format: missing data field',
        );
      }
      
      // Convert the new format to our existing format
      final flights = responseData['flights'] as List<dynamic>? ?? [];
      final airports = responseData['airports'] as List<dynamic>? ?? [];
      
      developer.log('🟢 API returned ${flights.length} flights and ${airports.length} airports', name: 'VoloFlightAPI');
      
      if (flights.isEmpty) {
        developer.log('⚠️ No flights found in API response', name: 'VoloFlightAPI');
        throw NetworkError(
          type: NetworkErrorType.notFound,
          message: 'No flights found for the specified route and date. Try adjusting your search criteria.',
        );
      }
      
      // Convert to our existing format
      final convertedData = {
        'best_flights': flights, // All flights are now in one array
        'other_flights': [], // Empty since we're not separating them
        'airports': airports,
      };
      
      final searchResponse = FlightSearchResponse.fromJson(convertedData);
      developer.log('✅ [PRODUCTION] Found ${searchResponse.bestFlights.length} flights', name: 'VoloFlightAPI');
      return searchResponse;
    } on NetworkError {
      rethrow;
    } catch (e) {
      developer.log('❌ [PRODUCTION] Flight search error: $e', name: 'VoloFlightAPI');
      throw NetworkError(
        type: NetworkErrorType.unknown,
        message: 'An unexpected error occurred while searching flights.',
        originalException: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}

class FlightSearchResponse {
  final List<FlightOption> bestFlights;
  final List<FlightOption> otherFlights;
  final List<AirportInfo> airports;

  FlightSearchResponse({
    required this.bestFlights,
    required this.otherFlights,
    required this.airports,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      bestFlights: (json['best_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight))
          .toList() ?? [],
      otherFlights: (json['other_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight))
          .toList() ?? [],
      airports: (json['airports'] as List<dynamic>?)
          ?.map((airport) => AirportInfo.fromJson(airport))
          .toList() ?? [],
    );
  }

  /// Filter flights by flight number (supports partial matches)
  void filterByFlightNumber(String searchFlightNumber) {
    // Count flights before filtering
    final initialBestFlights = bestFlights.length;
    final initialOtherFlights = otherFlights.length;
    
    // Filter best flights
    bestFlights.removeWhere((flight) {
      return !flight.containsFlightNumber(searchFlightNumber);
    });
    
    // Filter other flights
    otherFlights.removeWhere((flight) {
      return !flight.containsFlightNumber(searchFlightNumber);
    });
    
    // Log filtering results
    final remainingBestFlights = bestFlights.length;
    final remainingOtherFlights = otherFlights.length;
    
    developer.log('Filtered flights: ${initialBestFlights + initialOtherFlights} → ${remainingBestFlights + remainingOtherFlights}', name: 'VoloFlightAPI');
  }
}



class FlightOption {
  final List<Flight> flights;
  final int totalDuration;
  final int price;
  final String type;
  final String? airlineLogo;
  final String? bookingToken;
  final CarbonEmissions? carbonEmissions;
  final List<Map<String, dynamic>>? layovers;

  FlightOption({
    required this.flights,
    required this.totalDuration,
    required this.price,
    required this.type,
    this.airlineLogo,
    this.bookingToken,
    this.carbonEmissions,
    this.layovers,
  });

  factory FlightOption.fromJson(Map<String, dynamic> json) {
    return FlightOption(
      flights: (json['flights'] as List<dynamic>?)
          ?.map((flight) => Flight.fromJson(flight))
          .toList() ?? [],
      totalDuration: json['total_duration'] ?? 0,
      price: json['price'] ?? 0,
      type: json['type'] ?? '',
      airlineLogo: json['airline_logo'],
      bookingToken: json['booking_token'],
      carbonEmissions: json['carbon_emissions'] != null 
          ? CarbonEmissions.fromJson(json['carbon_emissions']) 
          : null,
      layovers: (json['layovers'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }

  /// Check if this flight option contains the given flight number (supports partial matches)
  bool containsFlightNumber(String searchFlightNumber) {
    final normalizedSearch = searchFlightNumber.replaceAll(' ', '').toUpperCase();
    return flights.any((flight) {
      final normalizedFlightNumber = flight.flightNumber.replaceAll(' ', '').toUpperCase();
      return normalizedFlightNumber.contains(normalizedSearch);
    });
  }

  /// Get all flight numbers in this trip as a formatted string
  String get flightNumbersString {
    return flights.map((f) => f.flightNumber).join(' · ');
  }

  /// Get the complete route (first departure to last arrival)
  String get completeRoute {
    if (flights.isEmpty) return '';
    final first = flights.first;
    final last = flights.last;
    return '${first.departureAirport.id} → ${last.arrivalAirport.id}';
  }
}

class Flight {
  final Airport departureAirport;
  final Airport arrivalAirport;
  final int duration;
  final String? airplane;
  final String airline;
  final String? airlineLogo;
  final String travelClass;
  final String flightNumber;
  final List<String> extensions;
  final bool? overnight;
  final bool? oftenDelayedByOver30Min;

  Flight({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.duration,
    this.airplane,
    required this.airline,
    this.airlineLogo,
    required this.travelClass,
    required this.flightNumber,
    required this.extensions,
    this.overnight,
    this.oftenDelayedByOver30Min,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      departureAirport: Airport.fromJson(json['departure_airport'] ?? {}),
      arrivalAirport: Airport.fromJson(json['arrival_airport'] ?? {}),
      duration: json['duration'] ?? 0,
      airplane: json['airplane'],
      airline: json['airline'] ?? '',
      airlineLogo: json['airline_logo'],
      travelClass: json['travel_class'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      extensions: (json['extensions'] as List<dynamic>?)
          ?.map((ext) => ext.toString())
          .toList() ?? [],
      overnight: json['overnight'],
      oftenDelayedByOver30Min: json['often_delayed_by_over_30_min'],
    );
  }
}

class Airport {
  final String name;
  final String id;
  final String time;

  Airport({
    required this.name,
    required this.id,
    required this.time,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class CarbonEmissions {
  final int thisFlight;
  final int typicalForThisRoute;
  final int differencePercent;

  CarbonEmissions({
    required this.thisFlight,
    required this.typicalForThisRoute,
    required this.differencePercent,
  });

  factory CarbonEmissions.fromJson(Map<String, dynamic> json) {
    return CarbonEmissions(
      thisFlight: json['this_flight'] ?? 0,
      typicalForThisRoute: json['typical_for_this_route'] ?? 0,
      differencePercent: json['difference_percent'] ?? 0,
    );
  }
}



class AirportInfo {
  final List<AirportDetail> departure;
  final List<AirportDetail> arrival;

  AirportInfo({
    required this.departure,
    required this.arrival,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      departure: (json['departure'] as List<dynamic>?)
          ?.map((airport) => AirportDetail.fromJson(airport))
          .toList() ?? [],
      arrival: (json['arrival'] as List<dynamic>?)
          ?.map((airport) => AirportDetail.fromJson(airport))
          .toList() ?? [],
    );
  }
}

class AirportDetail {
  final Airport airport;
  final String city;
  final String country;
  final String countryCode;
  final String? image;
  final String? thumbnail;

  AirportDetail({
    required this.airport,
    required this.city,
    required this.country,
    required this.countryCode,
    this.image,
    this.thumbnail,
  });

  factory AirportDetail.fromJson(Map<String, dynamic> json) {
    return AirportDetail(
      airport: Airport.fromJson(json['airport'] ?? {}),
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
      image: json['image'],
      thumbnail: json['thumbnail'],
    );
  }
} 