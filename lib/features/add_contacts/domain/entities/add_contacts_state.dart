import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_contacts_state.freezed.dart';

@freezed
class AddContactsState with _$AddContactsState {
  const factory AddContactsState({
    required List<Contact> selectedContacts,
    @Default(false) bool enableNotifications,
    @Default(false) bool showFlightUpdates,
    @Default(false) bool isDisclaimerExpanded,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _AddContactsState;
}

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String name,
    String? avatar,
    String? phoneNumber,
  }) = _Contact;
}

@freezed
class AddContactsArgs with _$AddContactsArgs {
  const factory AddContactsArgs({
    required dynamic selectedFlight,
    required String departureCity,
    required String departureAirportCode,
    required String departureImage,
    required String departureThumbnail,
    required String arrivalCity,
    required String arrivalAirportCode,
    required String arrivalImage,
    required String arrivalThumbnail,
  }) = _AddContactsArgs;
} 