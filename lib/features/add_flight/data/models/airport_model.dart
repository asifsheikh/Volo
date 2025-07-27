import '../../domain/entities/airport_entity.dart';

class AirportModel extends AirportEntity {
  const AirportModel({
    required super.city,
    required super.airport,
    required super.iata,
    super.countryCode = '',
    super.countryName = '',
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      city: json['city'] ?? '',
      airport: json['airport'] ?? '',
      iata: json['iata'] ?? '',
    );
  }

  factory AirportModel.fromApiJson(Map<String, dynamic> json) {
    return AirportModel(
      city: json['city'] ?? '',
      airport: json['airport'] ?? '',
      iata: json['iata_code'] ?? '',
      countryCode: json['country_code'] ?? '',
      countryName: json['country_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'airport': airport,
      'iata': iata,
      'countryCode': countryCode,
      'countryName': countryName,
    };
  }
} 