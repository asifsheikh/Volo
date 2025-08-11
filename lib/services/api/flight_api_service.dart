`import '../../core/services/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../models/flight/flight_model.dart';
import '../network_service.dart';

/// Flight API service using the new base service structure
class FlightApiService extends BaseService {
  FlightApiService() : super(AppConstants.baseApiUrl);

  /// Search for flights
  Future<ApiResponse<FlightSearchResponse>> searchFlights({
    required String departureIata,
    required String arrivalIata,
    required String date,
    String? flightNumber,
  }) async {
    final params = {
      'departureIata': departureIata,
      'arrivalIata': arrivalIata,
      'date': date,
      if (flightNumber != null && flightNumber.isNotEmpty) 'flightNumber': flightNumber,
    };

    final response = await get<FlightSearchResponse>(
      '/search',
      headers: {'Content-Type': 'application/json'},
      fromJson: (json) => FlightSearchResponse.fromJson(json),
    );

    return response;
  }

  /// Get flight details by ID
  Future<ApiResponse<Flight>> getFlightDetails(String flightId) async {
    final response = await get<Flight>(
      '/flights/$flightId',
      fromJson: (json) => Flight.fromJson(json),
    );

    return response;
  }

  /// Get popular routes
  Future<ApiResponse<List<FlightRoute>>> getPopularRoutes() async {
    final response = await get<List<FlightRoute>>(
      '/routes/popular',
      fromJson: (json) => (json as List)
          .map((item) => FlightRoute.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    return response;
  }
}

/// Flight search response model
class FlightSearchResponse extends BaseModel {
  final List<FlightOption> bestFlights;
  final List<FlightOption> otherFlights;
  final List<AirportInfo> airports;

  const FlightSearchResponse({
    required this.bestFlights,
    required this.otherFlights,
    required this.airports,
  });

  factory FlightSearchResponse.fromJson(Map<String, dynamic> json) {
    return FlightSearchResponse(
      bestFlights: (json['best_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight as Map<String, dynamic>))
          .toList() ?? [],
      otherFlights: (json['other_flights'] as List<dynamic>?)
          ?.map((flight) => FlightOption.fromJson(flight as Map<String, dynamic>))
          .toList() ?? [],
      airports: (json['airports'] as List<dynamic>?)
          ?.map((airport) => AirportInfo.fromJson(airport as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'best_flights': bestFlights.map((flight) => flight.toJson()).toList(),
      'other_flights': otherFlights.map((flight) => flight.toJson()).toList(),
      'airports': airports.map((airport) => airport.toJson()).toList(),
    };
  }

  @override
  bool isValid() => true;

  @override
  List<String> getValidationErrors() => [];

  @override
  FlightSearchResponse copyWith({
    List<FlightOption>? bestFlights,
    List<FlightOption>? otherFlights,
    List<AirportInfo>? airports,
  }) {
    return FlightSearchResponse(
      bestFlights: bestFlights ?? this.bestFlights,
      otherFlights: otherFlights ?? this.otherFlights,
      airports: airports ?? this.airports,
    );
  }
}

/// Flight option model (multiple flights in one journey)
class FlightOption extends BaseModel {
  final List<Flight> flights;
  final int totalDuration;
  final double price;
  final String type;
  final String? airlineLogo;
  final String? bookingToken;
  final CarbonEmissions? carbonEmissions;
  final List<Map<String, dynamic>>? layovers;

  const FlightOption({
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
          ?.map((flight) => Flight.fromJson(flight as Map<String, dynamic>))
          .toList() ?? [],
      totalDuration: json['total_duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      airlineLogo: json['airline_logo'],
      bookingToken: json['booking_token'],
      carbonEmissions: json['carbon_emissions'] != null
          ? CarbonEmissions.fromJson(json['carbon_emissions'])
          : null,
      layovers: json['layovers'] != null
          ? List<Map<String, dynamic>>.from(json['layovers'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'flights': flights.map((flight) => flight.toJson()).toList(),
      'total_duration': totalDuration,
      'price': price,
      'type': type,
      'airline_logo': airlineLogo,
      'booking_token': bookingToken,
      'carbon_emissions': carbonEmissions?.toJson(),
      'layovers': layovers,
    };
  }

  @override
  bool isValid() => flights.isNotEmpty && price > 0;

  @override
  List<String> getValidationErrors() {
    final errors = <String>[];
    if (flights.isEmpty) errors.add('At least one flight is required');
    if (price <= 0) errors.add('Price must be greater than 0');
    return errors;
  }

  @override
  FlightOption copyWith({
    List<Flight>? flights,
    int? totalDuration,
    double? price,
    String? type,
    String? airlineLogo,
    String? bookingToken,
    CarbonEmissions? carbonEmissions,
    List<Map<String, dynamic>>? layovers,
  }) {
    return FlightOption(
      flights: flights ?? this.flights,
      totalDuration: totalDuration ?? this.totalDuration,
      price: price ?? this.price,
      type: type ?? this.type,
      airlineLogo: airlineLogo ?? this.airlineLogo,
      bookingToken: bookingToken ?? this.bookingToken,
      carbonEmissions: carbonEmissions ?? this.carbonEmissions,
      layovers: layovers ?? this.layovers,
    );
  }
}

/// Airport information model
class AirportInfo extends BaseModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String iataCode;
  final String? thumbnail;

  const AirportInfo({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.iataCode,
    this.thumbnail,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      iataCode: json['iata_code'] ?? '',
      thumbnail: json['thumbnail'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'iata_code': iataCode,
      'thumbnail': thumbnail,
    };
  }

  @override
  bool isValid() => id.isNotEmpty && name.isNotEmpty && iataCode.isNotEmpty;

  @override
  List<String> getValidationErrors() {
    final errors = <String>[];
    if (id.isEmpty) errors.add('Airport ID is required');
    if (name.isEmpty) errors.add('Airport name is required');
    if (iataCode.isEmpty) errors.add('IATA code is required');
    return errors;
  }

  @override
  AirportInfo copyWith({
    String? id,
    String? name,
    String? city,
    String? country,
    String? iataCode,
    String? thumbnail,
  }) {
    return AirportInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      iataCode: iataCode ?? this.iataCode,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

/// Flight route model for popular routes
class FlightRoute extends BaseModel {
  final String departureAirport;
  final String arrivalAirport;
  final String departureCity;
  final String arrivalCity;
  final int frequency;
  final double averagePrice;

  const FlightRoute({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureCity,
    required this.arrivalCity,
    required this.frequency,
    required this.averagePrice,
  });

  factory FlightRoute.fromJson(Map<String, dynamic> json) {
    return FlightRoute(
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      departureCity: json['departure_city'] ?? '',
      arrivalCity: json['arrival_city'] ?? '',
      frequency: json['frequency'] ?? 0,
      averagePrice: (json['average_price'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_city': departureCity,
      'arrival_city': arrivalCity,
      'frequency': frequency,
      'average_price': averagePrice,
    };
  }

  @override
  bool isValid() => departureAirport.isNotEmpty && arrivalAirport.isNotEmpty;

  @override
  List<String> getValidationErrors() {
    final errors = <String>[];
    if (departureAirport.isEmpty) errors.add('Departure airport is required');
    if (arrivalAirport.isEmpty) errors.add('Arrival airport is required');
    return errors;
  }

  @override
  FlightRoute copyWith({
    String? departureAirport,
    String? arrivalAirport,
    String? departureCity,
    String? arrivalCity,
    int? frequency,
    double? averagePrice,
  }) {
    return FlightRoute(
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureCity: departureCity ?? this.departureCity,
      arrivalCity: arrivalCity ?? this.arrivalCity,
      frequency: frequency ?? this.frequency,
      averagePrice: averagePrice ?? this.averagePrice,
    );
  }
} 