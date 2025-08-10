// import '../../core/models/base_model.dart';

/// Trip model representing a user's flight trip
class Trip {
  final String id;
  final TripData tripData;
  final List<String> contactIds;
  final String status;
  final bool userNotifications;
  final TripMetadata metadata;

  const Trip({
    required this.id,
    required this.tripData,
    required this.contactIds,
    required this.status,
    required this.userNotifications,
    required this.metadata,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? '',
      tripData: TripData.fromJson(json['tripData'] ?? {}),
      contactIds: (json['contactIds'] as List<dynamic>?)
          ?.map((id) => id.toString())
          .toList() ?? [],
      status: json['status'] ?? 'scheduled',
      userNotifications: json['userNotifications'] ?? true,
      metadata: TripMetadata.fromJson(json['metadata'] ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripData': tripData.toJson(),
      'contactIds': contactIds,
      'status': status,
      'userNotifications': userNotifications,
      'metadata': metadata.toJson(),
    };
  }

  bool isValid() {
    // ID can be empty initially (will be set by Firestore)
    return tripData.isValid();
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    // Don't require ID initially (will be set by Firestore)
    errors.addAll(tripData.getValidationErrors());
    return errors;
  }

  Trip copyWith({
    String? id,
    TripData? tripData,
    List<String>? contactIds,
    String? status,
    bool? userNotifications,
    TripMetadata? metadata,
  }) {
    return Trip(
      id: id ?? this.id,
      tripData: tripData ?? this.tripData,
      contactIds: contactIds ?? this.contactIds,
      status: status ?? this.status,
      userNotifications: userNotifications ?? this.userNotifications,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Trip data containing flight information
class TripData {
  final String id;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final int totalDuration;
  final List<TripFlight> flights;

  const TripData({
    required this.id,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.totalDuration,
    required this.flights,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      id: json['id'] ?? '',
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      departureTime: DateTime.parse(json['departure_time']),
      totalDuration: json['total_duration'] ?? 0,
      flights: (json['flights'] as List<dynamic>?)
          ?.map((flight) => TripFlight.fromJson(flight as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_time': departureTime.toIso8601String(),
      'total_duration': totalDuration,
      'flights': flights.map((flight) => flight.toJson()).toList(),
    };
  }

  bool isValid() {
    // ID can be empty initially (will be set by Firestore)
    return departureAirport.isNotEmpty &&
        arrivalAirport.isNotEmpty &&
        flights.isNotEmpty;
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    // Don't require ID initially (will be set by Firestore)
    if (departureAirport.isEmpty) errors.add('Departure airport is required');
    if (arrivalAirport.isEmpty) errors.add('Arrival airport is required');
    if (flights.isEmpty) errors.add('At least one flight is required');
    return errors;
  }

  TripData copyWith({
    String? id,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureTime,
    int? totalDuration,
    List<TripFlight>? flights,
  }) {
    return TripData(
      id: id ?? this.id,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureTime: departureTime ?? this.departureTime,
      totalDuration: totalDuration ?? this.totalDuration,
      flights: flights ?? this.flights,
    );
  }
}

/// Individual flight within a trip
class TripFlight {
  final String flightNumber;
  final String airline;
  final String? airlineLogo;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int duration;
  final String? airplane;
  final String? travelClass;

  const TripFlight({
    required this.flightNumber,
    required this.airline,
    this.airlineLogo,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    this.airplane,
    this.travelClass,
  });

  factory TripFlight.fromJson(Map<String, dynamic> json) {
    return TripFlight(
      flightNumber: json['flight_number'] ?? '',
      airline: json['airline'] ?? '',
      airlineLogo: json['airline_logo'],
      departureAirport: json['departure_airport'] ?? '',
      arrivalAirport: json['arrival_airport'] ?? '',
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      duration: json['duration'] ?? 0,
      airplane: json['airplane'],
      travelClass: json['travel_class'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'flight_number': flightNumber,
      'airline': airline,
      'airline_logo': airlineLogo,
      'departure_airport': departureAirport,
      'arrival_airport': arrivalAirport,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'duration': duration,
      'airplane': airplane,
      'travel_class': travelClass,
    };
  }

  bool isValid() {
    return flightNumber.isNotEmpty &&
        airline.isNotEmpty &&
        departureAirport.isNotEmpty &&
        arrivalAirport.isNotEmpty;
  }

  List<String> getValidationErrors() {
    final errors = <String>[];
    if (flightNumber.isEmpty) errors.add('Flight number is required');
    if (airline.isEmpty) errors.add('Airline is required');
    if (departureAirport.isEmpty) errors.add('Departure airport is required');
    if (arrivalAirport.isEmpty) errors.add('Arrival airport is required');
    return errors;
  }

  TripFlight copyWith({
    String? flightNumber,
    String? airline,
    String? airlineLogo,
    String? departureAirport,
    String? arrivalAirport,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? duration,
    String? airplane,
    String? travelClass,
  }) {
    return TripFlight(
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
      airlineLogo: airlineLogo ?? this.airlineLogo,
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      duration: duration ?? this.duration,
      airplane: airplane ?? this.airplane,
      travelClass: travelClass ?? this.travelClass,
    );
  }
}

/// Trip metadata for tracking creation and updates
class TripMetadata {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String source;

  const TripMetadata({
    required this.createdAt,
    required this.updatedAt,
    this.source = 'manual',
  });

  factory TripMetadata.fromJson(Map<String, dynamic> json) {
    return TripMetadata(
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      source: json['source'] ?? 'manual',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'source': source,
    };
  }

  bool isValid() => true;

  List<String> getValidationErrors() => [];

  TripMetadata copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
  }) {
    return TripMetadata(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
    );
  }
} 