import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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

  // Load airports from asset
  Future<void> loadAirports(BuildContext context) async {
    isLoadingAirports = true;
    notifyListeners();
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/airports_global.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      allAirports = jsonList.map((json) => Airport.fromJson(json)).toList();
      isLoadingAirports = false;
      notifyListeners();
      debugPrint('Loaded  [32m [1m [4m [7m${allAirports.length} [0m airports');
      if (allAirports.isNotEmpty) {
        debugPrint('Sample airport: ${allAirports.first.displayName}');
      }
    } catch (e) {
      debugPrint('Error loading airports: $e');
      isLoadingAirports = false;
      notifyListeners();
    }
  }

  // Get airport suggestions
  Future<List<Airport>> getAirportSuggestions(String query) async {
    final lowercaseQuery = query.toLowerCase();
    final List<Airport> filtered = [];
    for (final airport in allAirports) {
      final cityLower = airport.city.toLowerCase();
      final airportLower = airport.airport.toLowerCase();
      final iataLower = airport.iata.toLowerCase();
      bool matches = false;
      if (iataLower == lowercaseQuery) {
        matches = true;
      } else if (iataLower.startsWith(lowercaseQuery)) {
        matches = true;
      } else if (cityLower.startsWith(lowercaseQuery)) {
        matches = true;
      } else if (airportLower.startsWith(lowercaseQuery)) {
        matches = true;
      } else if (cityLower.contains(lowercaseQuery) || 
                 airportLower.contains(lowercaseQuery) || 
                 iataLower.contains(lowercaseQuery)) {
        matches = true;
      }
      if (matches) {
        filtered.add(airport);
      }
    }
    filtered.sort((a, b) {
      final aScore = _calculateScore(a, lowercaseQuery);
      final bScore = _calculateScore(b, lowercaseQuery);
      return bScore.compareTo(aScore);
    });
    return filtered.take(8).toList();
  }

  int _calculateScore(Airport airport, String query) {
    final cityLower = airport.city.toLowerCase();
    final airportLower = airport.airport.toLowerCase();
    final iataLower = airport.iata.toLowerCase();
    if (iataLower == query) return 1000;
    if (iataLower.startsWith(query)) return 900;
    if (cityLower.startsWith(query)) return 800;
    if (airportLower.startsWith(query)) return 700;
    if (cityLower.contains(query) || airportLower.contains(query) || iataLower.contains(query)) {
      return 100;
    }
    return 0;
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

  @override
  void dispose() {
    flightNumberController.dispose();
    departureCityController.dispose();
    arrivalCityController.dispose();
    super.dispose();
  }
} 