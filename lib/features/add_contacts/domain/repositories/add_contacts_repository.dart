import '../entities/add_contacts_state.dart';

abstract class AddContactsRepository {
  /// Get contacts from device
  Future<List<Contact>> getDeviceContacts();
  
  /// Request contacts permission
  Future<bool> requestContactsPermission();
  
  /// Save trip to Firestore
  Future<void> saveTrip({
    required dynamic flightOption,
    required List<String> contactIds,
    required bool userNotifications,
    required String departureCity,
    required String arrivalCity,
  });
  
  /// Get current user ID
  String? getCurrentUserId();
} 