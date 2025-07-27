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
    // If airport name is the same as city, just show city with IATA
    if (airport.toLowerCase() == city.toLowerCase()) {
      return '$city ($iata)';
    }
    
    // If airport name contains city name, show the full airport name
    if (airport.toLowerCase().contains(city.toLowerCase())) {
      return '$city ($iata) – $airport';
    }
    
    // Otherwise show city and airport separately
    return '$city ($iata) – $airport';
  }

  @override
  List<Object> get props => [city, airport, iata, countryCode, countryName];
} 