import '../../core/models/base_model.dart';
import '../../core/constants/app_constants.dart';

/// Flight model representing a single flight
class Flight extends BaseModel {
  final String id;
  final String flightNumber;
  final String airline;
  final String? airlineLogo;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int duration; // in minutes
  final double price;
  final String? airplane;
  final String? bookingToken;
  final CarbonEmissions? carbonEmissions;

  Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    this.airlineLogo,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    this.airplane,
    this.bookingToken,
    this.carbonEmissions,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] ?? '',
      flightNumber: json['flight_number'] ?? '',
      airline: json['airline'] ?? '',
      airlineLogo: json['airline_logo'],
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      airplane: json['airplane'],
      bookingToken: json['booking_token'],
      carbonEmissions: json['carbon_emissions'] != null
          ? CarbonEmissions.fromJson(json['carbon_emissions'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flight_number': flightNumber,
      'airline': airline,
      'airline_logo': airlineLogo,
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'airplane': airplane,
      'booking_token': bookingToken,
      'carbon_emissions': carbonEmissions?.toJson(),
    };
  }

  @override
  bool isValid() {
    return id.isNotEmpty &&
        flightNumber.isNotEmpty &&
        airline.isNotEmpty &&
        departureAirport.isNotEmpty &&
        arrivalAirport.isNotEmpty &&
        price > 0;
  }

  @override
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    if (id.isEmpty) errors.add('Flight ID is required');
    if (flightNumber.isEmpty) errors.add('Flight number is required');
    if (airline.isEmpty) errors.add('Airline is required');
    if (departureAirport.isEmpty) errors.add('Departure airport is required');
    if (arrivalAirport.isEmpty) errors.add('Arrival airport is required');
    if (price <= 0) errors.add('Price must be greater than 0');
    
    return errors;
  }

  @override
  BaseModel copyWith() {
    return this;
  }

  @override
  Flight copyWith({
    String? id,
    String? flightNumber,
    String? airline,
    String? airlineLogo,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? duration,
    double? price,
    String? airplane,
    String? bookingToken,
    CarbonEmissions? carbonEmissions,
  }) {
    return Flight(
      id: id ?? this.id,
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      airlineLogo: airlineLogo ?? this.airlineLogo,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      airplane: airplane ?? this.airplane,
      bookingToken: bookingToken ?? this.bookingToken,
      carbonEmissions: carbonEmissions ?? this.carbonEmissions,
    );
  }
}

/// Carbon emissions data
class CarbonEmissions extends BaseModel {
  final double kgCO2;
  final String unit;

  CarbonEmissions({
    required this.kgCO2,
    required this.unit,
  });

  factory CarbonEmissions.fromJson(Map<String, dynamic> json) {
    return CarbonEmissions(
      kgCO2: (json['kg_co2'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'kg_co2': kgCO2,
      'unit': unit,
    };
  }

  @override
  bool isValid() => kgCO2 >= 0;

  @override
  List<String> getValidationErrors() {
    if (kgCO2 < 0) return ['Carbon emissions cannot be negative'];
    return [];
  }

  @override
  BaseModel copyWith() {
    return this;
  }

  @override
  CarbonEmissions copyWith({
    double? kgCO2,
    String? unit,
  }) {
    return CarbonEmissions(
      kgCO2: kgCO2 ?? this.kgCO2,
      unit: unit ?? this.unit,
    );
  }
} 