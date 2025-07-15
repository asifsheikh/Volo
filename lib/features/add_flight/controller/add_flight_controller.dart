import 'package:flutter/material.dart';
import '../models/airport.dart';

class AddFlightController extends ChangeNotifier {
  // Form fields
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController arrivalCityController = TextEditingController();
  DateTime? selectedDate;
  Airport? selectedDepartureAirport;
  Airport? selectedArrivalAirport;

  // State
  List<Airport> allAirports = [];
  bool isLoadingAirports = false;

  // Load airports (to be implemented)
  Future<void> loadAirports(BuildContext context) async {
    // TODO: Move airport loading logic here
  }

  // Get airport suggestions (to be implemented)
  Future<List<Airport>> getAirportSuggestions(String query) async {
    // TODO: Move suggestion logic here
    return [];
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