import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip/trip_model.dart';
import '../core/constants/app_constants.dart';

/// Service for managing trip data in Firestore
class TripService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a trip to Firestore
  static Future<String> saveTrip({
    required Trip trip,
    required String userId,
  }) async {
    try {
      // Validate trip data
      if (!trip.isValid()) {
        final errors = trip.getValidationErrors();
        throw Exception('Invalid trip data: ${errors.join(', ')}');
      }

      // Create trip document reference
      final tripRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(trip.id);

      // Save trip data
      await tripRef.set(trip.toJson());

      return trip.id;
    } catch (e) {
      throw Exception('Failed to save trip: $e');
    }
  }

  /// Create a trip from flight option and contacts
  static Trip createTripFromFlightOption({
    required dynamic flightOption, // FlightOption from search results
    required List<dynamic> contacts, // ContactModel from add contacts screen
    required bool userNotifications,
    required String departureCity,
    required String arrivalCity,
    String? source = 'manual',
  }) {
    final now = DateTime.now();
    final tripId = _generateTripId();

    // Convert FlightOption to TripFlight
    final tripFlights = flightOption.flights.map<TripFlight>((flight) {
      return TripFlight(
        flightNumber: flight.flightNumber,
        airline: flight.airline,
        airlineLogo: flight.airlineLogo,
        departureAirport: flight.departureAirport.id,
        arrivalAirport: flight.arrivalAirport.id,
        departureTime: _parseFlightTime(flight.departureAirport.time),
        arrivalTime: _parseFlightTime(flight.arrivalAirport.time),
        duration: flight.duration,
        airplane: flight.airplane,
        travelClass: flight.travelClass,
      );
    }).toList();

    // Create trip data
    final tripData = TripData(
      id: tripId,
      departureAirport: tripFlights.first.departureAirport,
      arrivalAirport: tripFlights.last.arrivalAirport,
      departureTime: tripFlights.first.departureTime,
      totalDuration: flightOption.totalDuration,
      flights: tripFlights,
    );

    // Convert contacts to TripContact
    final tripContacts = contacts.map<TripContact>((contact) {
      return TripContact(
        name: contact.name,
        phoneNumber: contact.phoneNumber ?? '',
        relationship: 'family', // Default as discussed
      );
    }).toList();

    // Create metadata
    final metadata = TripMetadata(
      createdAt: now,
      updatedAt: now,
      source: source ?? 'manual',
    );

    // Create and return trip
    return Trip(
      id: tripId,
      tripData: tripData,
      contacts: tripContacts,
      status: 'scheduled', // Initial status
      userNotifications: userNotifications,
      metadata: metadata,
    );
  }

  /// Get all trips for a user
  static Future<List<Trip>> getUserTrips(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .orderBy('metadata.createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Trip.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user trips: $e');
    }
  }

  /// Get a specific trip by ID
  static Future<Trip?> getTrip(String userId, String tripId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .get();

      if (docSnapshot.exists) {
        return Trip.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get trip: $e');
    }
  }

  /// Update trip status
  static Future<void> updateTripStatus({
    required String userId,
    required String tripId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .update({
        'status': status,
        'metadata.updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  /// Delete a trip
  static Future<void> deleteTrip({
    required String userId,
    required String tripId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(tripId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Generate a unique trip ID
  static String _generateTripId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'trip_${timestamp}_$random';
  }

  /// Parse flight time string to DateTime
  static DateTime _parseFlightTime(String timeString) {
    // Handle different time formats from the API
    // Example: "2025-12-10 04:10" or "2025-12-10T04:10:00Z"
    try {
      if (timeString.contains('T')) {
        return DateTime.parse(timeString);
      } else {
        // Format: "2025-12-10 04:10"
        final parts = timeString.split(' ');
        final datePart = parts[0];
        final timePart = parts[1];
        final dateTimeString = '${datePart}T${timePart}:00';
        return DateTime.parse(dateTimeString);
      }
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }

  /// Check if user has any trips
  static Future<bool> hasUserTrips(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get trip count for a user
  static Future<int> getUserTripCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
} 