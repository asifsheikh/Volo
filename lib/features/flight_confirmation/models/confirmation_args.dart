class ConfirmationArgs {
  final String fromCity;
  final String toCity;
  final List<String> contactNames;
  final List<String> contactAvatars;
  final dynamic selectedFlight; // Replace with your Flight model when available
  final String departureAirportCode;
  final String departureImage;
  final String departureThumbnail;
  final String arrivalAirportCode;
  final String arrivalImage;
  final String arrivalThumbnail;
  final bool enableNotifications;
  
  const ConfirmationArgs({
    required this.fromCity,
    required this.toCity,
    required this.contactNames,
    required this.contactAvatars,
    this.selectedFlight,
    required this.departureAirportCode,
    required this.departureImage,
    required this.departureThumbnail,
    required this.arrivalAirportCode,
    required this.arrivalImage,
    required this.arrivalThumbnail,
    this.enableNotifications = false,
  });
} 