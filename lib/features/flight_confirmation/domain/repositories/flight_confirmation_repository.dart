import '../entities/flight_confirmation_state.dart';
import '../../models/confirmation_args.dart';

abstract class FlightConfirmationRepository {
  /// Get confirmation data
  Future<FlightConfirmationState> getConfirmationData(ConfirmationArgs args);
  
  /// Mark confetti as shown for the journey
  Future<void> markConfettiShown();
  
  /// Check if confetti has been shown for the journey
  Future<bool> hasConfettiBeenShown();
  
  /// Reset confetti flag for new journey
  Future<void> resetConfettiForNewJourney();
} 