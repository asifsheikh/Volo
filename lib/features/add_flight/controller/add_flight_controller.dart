import 'package:flutter/material.dart';
import '../add_flight_screen.dart';

class AddFlightController extends ChangeNotifier {
  // Form controllers
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController arrivalCityController = TextEditingController();
  
  // Form state
  DateTime? selectedDate;
  String? selectedDepartureCity;
  String? selectedArrivalCity;
  Airport? selectedDepartureAirport;
  Airport? selectedArrivalAirport;
  
  // Airport data
  List<Airport> allAirports = [];
  bool isLoadingAirports = false;

  // Form validation getter
  bool get isFormValid {
    return selectedDate != null &&
        selectedDepartureAirport != null &&
        selectedArrivalAirport != null;
  }

  // Load airports (to be implemented)
  Future<void> loadAirports(BuildContext context) async {
    // TODO: Move airport loading logic here
  }

  // Get airport suggestions (to be implemented)
  Future<List<Airport>> getAirportSuggestions(String query) async {
    // TODO: Move suggestion logic here
    return [];
  }

  // Airport selection methods
  void onDepartureAirportSelected(Airport airport) {
    departureCityController.text = airport.displayName;
    selectedDepartureCity = airport.displayName;
    selectedDepartureAirport = airport;
    notifyListeners();
  }

  void onArrivalAirportSelected(Airport airport) {
    arrivalCityController.text = airport.displayName;
    selectedArrivalCity = airport.displayName;
    selectedArrivalAirport = airport;
    notifyListeners();
  }

  // Date selection
  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  // Validation, extraction, and other business logic will be added here

  @override
  void dispose() {
    flightNumberController.dispose();
    departureCityController.dispose();
    arrivalCityController.dispose();
    super.dispose();
  }
} 