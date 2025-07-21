import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer' as developer;
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
      debugPrint('Loaded ${allAirports.length} airports');
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

  // Find airport object by city name and IATA code (only exact matches)
  Airport? findAirportByCityAndIata(String city, String iata) {
    final normalizedCity = city.toLowerCase().trim();
    final normalizedIata = iata.toUpperCase().trim();
    
    developer.log('AddFlightController: Looking for airport - City: "$city", IATA: "$iata"', name: 'VoloUpload');
    
    // Only try exact matches - no auto-selection for city names
    for (final airport in allAirports) {
      final airportCity = airport.city.toLowerCase().trim();
      final airportIata = airport.iata.toUpperCase().trim();
      
      // Check if city and IATA code match exactly
      if (airportCity == normalizedCity && airportIata == normalizedIata) {
        developer.log('AddFlightController: Found exact match: ${airport.displayName}', name: 'VoloUpload');
        return airport;
      }
    }
    
    developer.log('AddFlightController: Could not find exact airport match for $city ($iata)', name: 'VoloUpload');
    return null;
  }

  // Populate form fields from extracted ticket data
  void populateFormFromTicket(Map<String, dynamic> ticketData) {
    try {
      // Extract flight number
      final String? flightNumber = ticketData['flightNumber'] as String?;
      if (flightNumber != null && flightNumber.isNotEmpty) {
        flightNumberController.text = flightNumber;
      }

      // Extract and set departure date
      final String? departureDateStr = ticketData['departureDate'] as String?;
      if (departureDateStr != null) {
        final DateTime? parsedDate = DateTime.tryParse(departureDateStr);
        if (parsedDate != null) {
          setSelectedDate(parsedDate);
        }
      }

      // Extract departure information
      final String? departureCity = ticketData['departureCity'] as String?;
      final String? departureAirport = ticketData['departureAirport'] as String?;
      if (departureCity != null && departureAirport != null) {
        // Check if departureAirport is a valid IATA code (3 uppercase letters)
        final bool isDepartureValidIata = RegExp(r'^[A-Z]{3}$').hasMatch(departureAirport.toUpperCase().trim());
        
        if (isDepartureValidIata) {
          // If it's a valid IATA code, try to find the airport
          final Airport? departureAirportObj = findAirportByCityAndIata(departureCity, departureAirport);
          if (departureAirportObj != null) {
            // Use the airport object to populate (same as dropdown selection)
            onDepartureAirportSelected(departureAirportObj);
            developer.log('AddFlightController: Found departure airport: ${departureAirportObj.displayName}', name: 'VoloUpload');
          } else {
            // Valid IATA but not found in database, pre-populate with city name
            departureCityController.text = departureCity;
            selectedDepartureCity = departureCity;
            selectedDepartureAirport = null; // Clear airport object since we only have city name
            notifyListeners();
            developer.log('AddFlightController: Pre-populated departure with city: $departureCity (IATA not found)', name: 'VoloUpload');
          }
        } else {
          // Not a valid IATA code, pre-populate with city name only
          departureCityController.text = departureCity;
          selectedDepartureCity = departureCity;
          selectedDepartureAirport = null; // Clear airport object since we only have city name
          notifyListeners();
          developer.log('AddFlightController: Pre-populated departure with city: $departureCity (not valid IATA)', name: 'VoloUpload');
        }
      }

      // Extract arrival information
      final String? arrivalCity = ticketData['arrivalCity'] as String?;
      final String? arrivalAirport = ticketData['arrivalAirport'] as String?;
      if (arrivalCity != null && arrivalAirport != null) {
        // Check if arrivalAirport is a valid IATA code (3 uppercase letters)
        final bool isArrivalValidIata = RegExp(r'^[A-Z]{3}$').hasMatch(arrivalAirport.toUpperCase().trim());
        
        if (isArrivalValidIata) {
          // If it's a valid IATA code, try to find the airport
          final Airport? arrivalAirportObj = findAirportByCityAndIata(arrivalCity, arrivalAirport);
          if (arrivalAirportObj != null) {
            // Use the airport object to populate (same as dropdown selection)
            onArrivalAirportSelected(arrivalAirportObj);
            developer.log('AddFlightController: Found arrival airport: ${arrivalAirportObj.displayName}', name: 'VoloUpload');
          } else {
            // Valid IATA but not found in database, pre-populate with city name
            arrivalCityController.text = arrivalCity;
            selectedArrivalCity = arrivalCity;
            selectedArrivalAirport = null; // Clear airport object since we only have city name
            notifyListeners();
            developer.log('AddFlightController: Pre-populated arrival with city: $arrivalCity (IATA not found)', name: 'VoloUpload');
          }
        } else {
          // Not a valid IATA code, pre-populate with city name only
          arrivalCityController.text = arrivalCity;
          selectedArrivalCity = arrivalCity;
          selectedArrivalAirport = null; // Clear airport object since we only have city name
          notifyListeners();
          developer.log('AddFlightController: Pre-populated arrival with city: $arrivalCity (not valid IATA)', name: 'VoloUpload');
        }
      }

      developer.log('AddFlightController: Form populated with ticket data: $ticketData', name: 'VoloUpload');
    } catch (e) {
      developer.log('AddFlightController: Error populating form from ticket data: $e', name: 'VoloUpload');
    }
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