import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/add_contacts_state.dart' as domain;
import '../../../../services/trip_service.dart';

part 'add_contacts_local_data_source.g.dart';

/// Local data source for add contacts
@riverpod
class AddContactsLocalDataSource extends _$AddContactsLocalDataSource {
  @override
  Future<void> build() async {
    throw UnimplementedError('This provider should not be used directly');
  }

  /// Get contacts from device
  Future<List<domain.Contact>> getDeviceContacts() async {
    try {
      // Get all contacts with phone numbers
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers and convert to domain entities
      final contactsWithPhones = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) {
        final phoneNumber = contact.phones.first.number;
        final contactName = contact.displayName.isNotEmpty 
            ? contact.displayName 
            : (contact.name.first.isNotEmpty || contact.name.last.isNotEmpty)
                ? '${contact.name.first} ${contact.name.last}'.trim()
                : 'Unknown Contact';
        
        return domain.Contact(
          name: contactName,
          phoneNumber: phoneNumber,
          avatar: null, // Not loading photos for performance
        );
      }).toList();

      return contactsWithPhones;
    } catch (e) {
      throw Exception('Failed to get device contacts: $e');
    }
  }

  /// Request contacts permission
  Future<bool> requestContactsPermission() async {
    try {
      return await FlutterContacts.requestPermission(readonly: true);
    } catch (e) {
      throw Exception('Failed to request contacts permission: $e');
    }
  }

  /// Save trip to Firestore
  Future<void> saveTrip({
    required dynamic flightOption,
    required List<domain.Contact> contacts,
    required bool userNotifications,
    required String departureCity,
    required String arrivalCity,
  }) async {
    try {
      // Get current user ID
      final userId = TripService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Convert domain contacts to ContactModel for TripService
      final contactModels = contacts.map((contact) => ContactModel(
        name: contact.name,
        phoneNumber: contact.phoneNumber,
        avatar: contact.avatar,
      )).toList();

      // Create trip from flight option and contacts
      final trip = TripService.createTripFromFlightOption(
        flightOption: flightOption,
        contacts: contactModels,
        userNotifications: userNotifications,
        departureCity: departureCity,
        arrivalCity: arrivalCity,
      );

      // Save trip to Firestore
      await TripService.saveTrip(
        trip: trip,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Failed to save trip: $e');
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return TripService.getCurrentUserId();
  }
}

// Temporary ContactModel for TripService compatibility
class ContactModel {
  final String name;
  final String? avatar;
  final String? phoneNumber;
  
  ContactModel({
    required this.name,
    this.avatar,
    this.phoneNumber,
  });
} 