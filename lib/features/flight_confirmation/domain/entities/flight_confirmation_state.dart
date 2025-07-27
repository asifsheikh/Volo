import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_confirmation_state.freezed.dart';

@freezed
class FlightConfirmationState with _$FlightConfirmationState {
  const factory FlightConfirmationState({
    required String fromCity,
    required String toCity,
    required List<String> contactNames,
    required List<String> contactAvatars,
    dynamic selectedFlight,
    required String departureAirportCode,
    required String departureImage,
    required String departureThumbnail,
    required String arrivalAirportCode,
    required String arrivalImage,
    required String arrivalThumbnail,
    @Default(false) bool enableNotifications,
    @Default(false) bool hasShownConfetti,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _FlightConfirmationState;
} 