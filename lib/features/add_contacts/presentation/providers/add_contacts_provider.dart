import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../domain/entities/add_contacts_state.dart' as domain;
import '../../domain/usecases/get_device_contacts.dart';
import '../../domain/usecases/save_trip.dart';

part 'add_contacts_provider.g.dart';

/// Provider for add contacts state management
@riverpod
class AddContactsProvider extends _$AddContactsProvider {
  @override
  domain.AddContactsState build() {
    return const domain.AddContactsState(
      selectedContacts: [],
      enableNotifications: false,
      showFlightUpdates: false,
      isDisclaimerExpanded: false,
      isLoading: false,
      isSaving: false,
    );
  }

  /// Add a contact to the selected list
  void addContact(domain.Contact contact) {
    final currentState = state;
    final updatedContacts = [...currentState.selectedContacts, contact];
    state = currentState.copyWith(selectedContacts: updatedContacts);
  }

  /// Remove a contact from the selected list
  void removeContact(int index) {
    final currentState = state;
    final updatedContacts = List<domain.Contact>.from(currentState.selectedContacts);
    updatedContacts.removeAt(index);
    state = currentState.copyWith(selectedContacts: updatedContacts);
  }

  /// Toggle notifications
  void toggleNotifications() {
    final currentState = state;
    state = currentState.copyWith(enableNotifications: !currentState.enableNotifications);
  }

  /// Toggle flight updates visibility
  void toggleFlightUpdates() {
    final currentState = state;
    state = currentState.copyWith(showFlightUpdates: !currentState.showFlightUpdates);
  }

  /// Toggle disclaimer expansion
  void toggleDisclaimer() {
    final currentState = state;
    state = currentState.copyWith(isDisclaimerExpanded: !currentState.isDisclaimerExpanded);
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    final currentState = state;
    state = currentState.copyWith(isLoading: isLoading);
  }

  /// Set saving state
  void setSaving(bool isSaving) {
    final currentState = state;
    state = currentState.copyWith(isSaving: isSaving);
  }

  /// Set error message
  void setError(String? errorMessage) {
    final currentState = state;
    state = currentState.copyWith(errorMessage: errorMessage);
  }

  /// Clear error message
  void clearError() {
    final currentState = state;
    state = currentState.copyWith(errorMessage: null);
  }

  /// Check if contact already exists
  bool contactExists(domain.Contact contact) {
    return state.selectedContacts.any((c) => 
        c.phoneNumber == contact.phoneNumber || c.name == contact.name);
  }

  /// Get if any action has been taken
  bool get hasActionTaken {
    return state.enableNotifications || state.selectedContacts.isNotEmpty;
  }

  /// Pick a contact from device
  Future<void> pickContact() async {
    try {
      // Request permission to access contacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setError('We need access to your contacts to add people to notify.');
        return;
      }

      // Get all contacts with phone numbers
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers
      final contactsWithPhones = contacts.where((contact) => contact.phones.isNotEmpty).toList();

      if (contactsWithPhones.isEmpty) {
        setError('No contacts with phone numbers found in your device.');
        return;
      }

      // Get list of already selected phone numbers
      final selectedPhoneNumbers = state.selectedContacts
          .where((contact) => contact.phoneNumber != null)
          .map((contact) => contact.phoneNumber!)
          .toList();

      // For now, just pick the first contact with a phone number
      // In a real implementation, you'd show a contact picker dialog
      final selectedContact = contactsWithPhones.firstWhere(
        (contact) => !selectedPhoneNumbers.contains(contact.phones.first.number),
        orElse: () => contactsWithPhones.first,
      );

      final phoneNumber = selectedContact.phones.first.number;
      final contactName = selectedContact.displayName.isNotEmpty 
          ? selectedContact.displayName 
          : (selectedContact.name.first.isNotEmpty || selectedContact.name.last.isNotEmpty)
              ? '${selectedContact.name.first} ${selectedContact.name.last}'.trim()
              : 'Unknown Contact';
      
      // Check if contact already exists
      if (contactExists(domain.Contact(name: contactName, phoneNumber: phoneNumber))) {
        setError('This contact is already added to your list.');
        return;
      }
      
      // Add the contact
      addContact(domain.Contact(
        name: contactName,
        phoneNumber: phoneNumber,
      ));
      
      clearError();
    } catch (e) {
      setError('Unable to access contacts. Please try again.');
    }
  }
} 