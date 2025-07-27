import '../../domain/entities/flight_entity.dart';

class FlightModel extends FlightEntity {
  const FlightModel({
    super.id,
    required super.departureCity,
    required super.departureAirport,
    required super.departureIata,
    required super.arrivalCity,
    required super.arrivalAirport,
    required super.arrivalIata,
    required super.departureDate,
    required super.arrivalDate,
    super.airline,
    super.flightNumber,
    super.gate,
    super.terminal,
    super.status,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'],
      departureCity: json['departureCity'] ?? '',
      departureAirport: json['departureAirport'] ?? '',
      departureIata: json['departureIata'] ?? '',
      arrivalCity: json['arrivalCity'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      arrivalIata: json['arrivalIata'] ?? '',
      departureDate: DateTime.parse(json['departureDate']),
      arrivalDate: DateTime.parse(json['arrivalDate']),
      airline: json['airline'],
      flightNumber: json['flightNumber'],
      gate: json['gate'],
      terminal: json['terminal'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departureCity': departureCity,
      'departureAirport': departureAirport,
      'departureIata': departureIata,
      'arrivalCity': arrivalCity,
      'arrivalAirport': arrivalAirport,
      'arrivalIata': arrivalIata,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
      'airline': airline,
      'flightNumber': flightNumber,
      'gate': gate,
      'terminal': terminal,
      'status': status,
    };
  }
} 