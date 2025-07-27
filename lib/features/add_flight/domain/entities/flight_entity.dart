import 'package:equatable/equatable.dart';

class FlightEntity extends Equatable {
  final String? id;
  final String departureCity;
  final String departureAirport;
  final String departureIata;
  final String arrivalCity;
  final String arrivalAirport;
  final String arrivalIata;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final String? airline;
  final String? flightNumber;
  final String? gate;
  final String? terminal;
  final String? status;

  const FlightEntity({
    this.id,
    required this.departureCity,
    required this.departureAirport,
    required this.departureIata,
    required this.arrivalCity,
    required this.arrivalAirport,
    required this.arrivalIata,
    required this.departureDate,
    required this.arrivalDate,
    this.airline,
    this.flightNumber,
    this.gate,
    this.terminal,
    this.status,
  });

  @override
  List<Object?> get props => [
        id,
        departureCity,
        departureAirport,
        departureIata,
        arrivalCity,
        arrivalAirport,
        arrivalIata,
        departureDate,
        arrivalDate,
        airline,
        flightNumber,
        gate,
        terminal,
        status,
      ];
} 