import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/flight_confirmation_state.dart' as domain;
import '../repositories/flight_confirmation_repository.dart';
import '../../data/repositories/flight_confirmation_repository_impl.dart';
import '../../models/confirmation_args.dart';

part 'get_confirmation_data.g.dart';

/// Use case for getting confirmation data
@riverpod
class GetConfirmationData extends _$GetConfirmationData {
  @override
  Future<domain.FlightConfirmationState> build(ConfirmationArgs args) async {
    return _getConfirmationData(args);
  }

  Future<domain.FlightConfirmationState> _getConfirmationData(ConfirmationArgs args) async {
    try {
      final repository = ref.read(flightConfirmationRepositoryImplProvider.notifier);
      
      // Get confirmation data
      final confirmationData = await repository.getConfirmationData(args);
      
      return confirmationData;
    } catch (e) {
      throw Exception('Failed to get confirmation data: $e');
    }
  }

  /// Mark confetti as shown
  Future<void> markConfettiShown() async {
    try {
      final repository = ref.read(flightConfirmationRepositoryImplProvider.notifier);
      await repository.markConfettiShown();
    } catch (e) {
      throw Exception('Failed to mark confetti as shown: $e');
    }
  }

  /// Check if confetti has been shown
  Future<bool> hasConfettiBeenShown() async {
    try {
      final repository = ref.read(flightConfirmationRepositoryImplProvider.notifier);
      return await repository.hasConfettiBeenShown();
    } catch (e) {
      throw Exception('Failed to check confetti status: $e');
    }
  }

  /// Reset confetti for new journey
  Future<void> resetConfettiForNewJourney() async {
    try {
      final repository = ref.read(flightConfirmationRepositoryImplProvider.notifier);
      await repository.resetConfettiForNewJourney();
    } catch (e) {
      throw Exception('Failed to reset confetti: $e');
    }
  }
} 