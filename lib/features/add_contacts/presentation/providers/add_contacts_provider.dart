import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/add_contacts_state.dart' as domain;
import '../../../my_circle/presentation/widgets/my_circle_contact_picker_dialog.dart';
import '../../../my_circle/data/models/my_circle_contact_model.dart';
import '../../../../services/my_circle_service.dart';
import '../../../../main.dart';

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

  /// Pick a contact from My Circle
  Future<void> pickContact() async {
    try {
      setLoading(true);
      
      // Get contacts from user's My Circle
      final List<MyCircleContactModel> myCircleContacts = await MyCircleService.getMyCircleContacts();

      if (myCircleContacts.isEmpty) {
        setError('No contacts found in your circle. Please add contacts to your circle first.');
        setLoading(false);
        return;
      }

      // Get list of already selected phone numbers
      final selectedPhoneNumbers = state.selectedContacts
          .where((contact) => contact.phoneNumber != null)
          .map((contact) => contact.phoneNumber!)
          .toList();

      // Show My Circle contact picker dialog
      final selectedContact = await showDialog<MyCircleContactModel>(
        context: navigatorKey.currentContext!,
        builder: (context) => MyCircleContactPickerDialog(
          contacts: myCircleContacts,
          selectedPhoneNumbers: selectedPhoneNumbers,
        ),
      );

      if (selectedContact == null) {
        setLoading(false);
        return; // User cancelled
      }

      // Check if contact already exists
      if (contactExists(domain.Contact(
        id: selectedContact.id, 
        name: selectedContact.name, 
        phoneNumber: selectedContact.whatsappNumber
      ))) {
        setError('This contact is already added to your list.');
        setLoading(false);
        return;
      }
      
      // Add the contact
      addContact(domain.Contact(
        id: selectedContact.id,
        name: selectedContact.name,
        phoneNumber: selectedContact.whatsappNumber,
      ));
      
      clearError();
      setLoading(false);
    } catch (e) {
      setError('Unable to load contacts from your circle. Please try again.');
      setLoading(false);
    }
  }
} 