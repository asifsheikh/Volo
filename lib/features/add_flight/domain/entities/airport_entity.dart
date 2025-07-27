import 'package:equatable/equatable.dart';

class AirportEntity extends Equatable {
  final String city;
  final String airport;
  final String iata;
  final String countryCode;
  final String countryName;

  const AirportEntity({
    required this.city,
    required this.airport,
    required this.iata,
    this.countryCode = '',
    this.countryName = '',
  });

  String get displayName {
    // Show city name with IATA code
    return '$city ($iata)';
  }

  @override
  List<Object> get props => [city, airport, iata, countryCode, countryName];
} 