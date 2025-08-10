import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/flight_confirmation_state.dart' as domain;
import '../../models/confirmation_args.dart';

part 'flight_confirmation_local_data_source.g.dart';

/// Local data source for flight confirmation
@riverpod
class FlightConfirmationLocalDataSource extends _$FlightConfirmationLocalDataSource {
  static const String _confettiShownKey = 'confetti_shown_for_journey';
  
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get confirmation data
  Future<domain.FlightConfirmationState> getConfirmationData(ConfirmationArgs args) async {
    try {
      // Convert ConfirmationArgs to FlightConfirmationState
      final confirmationState = domain.FlightConfirmationState(
        fromCity: args.fromCity,
        toCity: args.toCity,
        contactNames: args.contactNames,
        selectedFlight: args.selectedFlight,
        departureAirportCode: args.departureAirportCode,
        departureImage: args.departureImage,
        departureThumbnail: args.departureThumbnail,
        arrivalAirportCode: args.arrivalAirportCode,
        arrivalImage: args.arrivalImage,
        arrivalThumbnail: args.arrivalThumbnail,
        enableNotifications: args.enableNotifications,
        hasShownConfetti: await hasConfettiBeenShown(),
      );
      
      return confirmationState;
    } catch (e) {
      throw Exception('Failed to get confirmation data: $e');
    }
  }

  /// Mark confetti as shown for the journey
  Future<void> markConfettiShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_confettiShownKey, true);
    } catch (e) {
      throw Exception('Failed to mark confetti as shown: $e');
    }
  }

  /// Check if confetti has been shown for the journey
  Future<bool> hasConfettiBeenShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_confettiShownKey) ?? false;
    } catch (e) {
      throw Exception('Failed to check confetti status: $e');
    }
  }

  /// Reset confetti flag for new journey
  Future<void> resetConfettiForNewJourney() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_confettiShownKey, false);
    } catch (e) {
      throw Exception('Failed to reset confetti: $e');
    }
  }
} 