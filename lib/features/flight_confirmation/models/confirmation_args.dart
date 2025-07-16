class ConfirmationArgs {
  final String fromCity;
  final String toCity;
  final List<String> contactNames;
  final List<String> contactAvatars;
  final dynamic selectedFlight; // Replace with your Flight model when available
  final String departureThumbnail;
  final String arrivalThumbnail;
  
  const ConfirmationArgs({
    required this.fromCity,
    required this.toCity,
    required this.contactNames,
    required this.contactAvatars,
    this.selectedFlight,
    required this.departureThumbnail,
    required this.arrivalThumbnail,
  });
} 