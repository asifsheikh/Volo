import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'remote_config_service.dart';
import 'dart:developer' as developer;

class FlightApiService {
  static const String _baseUrl = 'https://serpapi.com/search.json';
  static const String _apiKey = 'e9f50763e5d701bdb20b8b0619488341b02f382fb648c80c336b92eb004635f2';
  
  /// Get whether to use mock API based on remote config
  static bool get _useMockApi {
    return RemoteConfigService().getUseMockFlightData();
  }
  
  /// Get current data source for debugging
  static String getCurrentDataSource() {
    return _useMockApi ? 'Mock Data' : 'Real API';
  }
  
  /// Get remote config status for debugging
  static Map<String, dynamic> getRemoteConfigStatus() {
    return RemoteConfigService().getAllConfigValues();
  }
  


  /// Search for flights using either Mock Data or the real API
  static Future<FlightSearchResponse> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required String date,
    String? flightNumber,
  }) async {
    // Get the current remote config value
    final useMockData = _useMockApi;
    
    developer.log('Searching flights: $departureIata → $arrivalIata on $date', name: 'VoloFlightAPI');
    
    if (useMockData) {
      // --- MOCK API RESPONSE ---
      try {
        developer.log('🔴 Using MOCK flight data', name: 'VoloFlightAPI');
        // Load mock data from JSON file
        final String jsonString = await rootBundle.loadString('assets/mock_flights_response.json');
        final Map<String, dynamic> data = json.decode(jsonString);
        // Update search parameters to match the current search
        data['search_parameters'] = {
          'engine': 'google_flights',
          'hl': 'en',
          'gl': 'us',
          'type': '2',
          'departure_id': departureIata,
          'arrival_id': arrivalIata,
          'outbound_date': date,
          'currency': 'USD'
        };
        // Update search metadata
        data['search_metadata'] = {
          'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
          'status': 'Success',
          'created_at': DateTime.now().toUtc().toString(),
          'processed_at': DateTime.now().toUtc().toString(),
          'total_time_taken': 0.1
        };
        // (airports array is left as-is from the mock JSON)
        final searchResponse = FlightSearchResponse.fromJson(data);
        // Filter by flight number if provided
        if (flightNumber != null && flightNumber.isNotEmpty) {
          searchResponse.filterByFlightNumber(flightNumber);
        }
        developer.log('✅ [MOCK] Found ${searchResponse.bestFlights.length} flights', name: 'VoloFlightAPI');
        return searchResponse;
      } catch (e) {
        developer.log('❌ [MOCK] Flight search error: $e', name: 'VoloFlightAPI');
        rethrow;
      }
    } else {
      // --- REAL API RESPONSE ---
      try {
        developer.log('🟢 Using REAL flight API', name: 'VoloFlightAPI');
        
        final queryParameters = {
          'engine': 'google_flights',
          'departure_id': departureIata,
          'arrival_id': arrivalIata,
          'outbound_date': date,
          'type': '2', // One-way trip
          'api_key': _apiKey,
        };
        
        final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);

        final response = await http.get(uri);
        developer.log('🟢 API Response Status: ${response.statusCode}', name: 'VoloFlightAPI');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          developer.log('🟢 API Response received successfully', name: 'VoloFlightAPI');
          
          if (data['error'] != null) {
            developer.log('❌ API Error: ${data['error']}', name: 'VoloFlightAPI');
            throw Exception('API Error: ${data['error']}');
          }
          
          // Check if we have any flights
          final bestFlights = data['best_flights'] as List<dynamic>? ?? [];
          final otherFlights = data['other_flights'] as List<dynamic>? ?? [];
          
          developer.log('🟢 API returned ${bestFlights.length} best flights and ${otherFlights.length} other flights', name: 'VoloFlightAPI');
          
          if (bestFlights.isEmpty && otherFlights.isEmpty) {
            developer.log('⚠️ No flights found in API response', name: 'VoloFlightAPI');
            throw Exception('No flights found for the specified route and date. Try adjusting your search criteria.');
          }
          
          final searchResponse = FlightSearchResponse.fromJson(data);
          // Filter by flight number if provided
          if (flightNumber != null && flightNumber.isNotEmpty) {
            searchResponse.filterByFlightNumber(flightNumber);
          }
          developer.log('✅ [REAL] Found ${searchResponse.bestFlights.length} flights', name: 'VoloFlightAPI');
          return searchResponse;
        } else {
          throw Exception('HTTP Error: ${response.statusCode}');
        }
      } catch (e) {
        developer.log('❌ [REAL] Flight search error: $e', name: 'VoloFlightAPI');
        // Re-throw the original error so the user sees the actual API error
        rethrow;
      }
    }
  }
}

class FlightSearchResponse {
  final SearchMetadata searchMetadata;
  final SearchParameters searchParameters;
  final List<FlightOption> bestFlights;
  final List<FlightOption> otherFlights;
  final PriceInsights? priceInsights;
  final List<AirportInfo> airports;

  FlightSearchResponse({
    required this.searchMetadata,
    required this.searchParameters,
    required this.bestFlights,
    required this.otherFlights,
    this.priceInsights,
    required this.airports,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      searchMetadata: SearchMetadata.fromJson(json['search_metadata'] ?? {}),
      searchParameters: SearchParameters.fromJson(json['search_parameters'] ?? {}),
      bestFlights: (json['best_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight))
          .toList() ?? [],
      otherFlights: (json['other_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight))
          .toList() ?? [],
      priceInsights: json['price_insights'] != null 
          ? PriceInsights.fromJson(json['price_insights']) 
          : null,
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

class SearchMetadata {
  final String id;
  final String status;
  final String createdAt;

  SearchMetadata({
    required this.id,
    required this.status,
    required this.createdAt,
  });

  factory SearchMetadata.fromJson(Map<String, dynamic> json) {
    return SearchMetadata(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SearchParameters {
  final String engine;
  final String departureId;
  final String arrivalId;
  final String outboundDate;
  final String type;

  SearchParameters({
    required this.engine,
    required this.departureId,
    required this.arrivalId,
    required this.outboundDate,
    required this.type,
  });

  factory SearchParameters.fromJson(Map<String, dynamic> json) {
    return SearchParameters(
      engine: json['engine'] ?? '',
      departureId: json['departure_id'] ?? '',
      arrivalId: json['arrival_id'] ?? '',
      outboundDate: json['outbound_date'] ?? '',
      type: json['type'] ?? '',
    );
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

class PriceInsights {
  final int lowestPrice;
  final String priceLevel;
  final List<int> typicalPriceRange;
  final List<List<int>> priceHistory;

  PriceInsights({
    required this.lowestPrice,
    required this.priceLevel,
    required this.typicalPriceRange,
    required this.priceHistory,
  });

  factory PriceInsights.fromJson(Map<String, dynamic> json) {
    return PriceInsights(
      lowestPrice: json['lowest_price'] ?? 0,
      priceLevel: json['price_level'] ?? '',
      typicalPriceRange: (json['typical_price_range'] as List<dynamic>?)
          ?.map((price) => price as int)
          .toList() ?? [],
      priceHistory: (json['price_history'] as List<dynamic>?)
          ?.map((item) => (item as List<dynamic>).map((p) => p as int).toList())
          .toList() ?? [],
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