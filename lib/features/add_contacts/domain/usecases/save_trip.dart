import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/add_contacts_state.dart' as domain;
import '../repositories/add_contacts_repository.dart';
import '../../data/repositories/add_contacts_repository_impl.dart';

part 'save_trip.g.dart';

/// Use case for saving trip
@riverpod
class SaveTrip extends _$SaveTrip {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  Future<void> saveTrip({
    required dynamic flightOption,
    required List<String> contactIds,
    required bool userNotifications,
    required String departureCity,
    required String arrivalCity,
  }) async {
    try {
      final repository = ref.read(addContactsRepositoryImplProvider.notifier);
      
      // Save trip
      await repository.saveTrip(
        flightOption: flightOption,
        contactIds: contactIds,
        userNotifications: userNotifications,
        departureCity: departureCity,
        arrivalCity: arrivalCity,
      );
    } catch (e) {
      throw Exception('Failed to save trip: $e');
    }
  }
} 