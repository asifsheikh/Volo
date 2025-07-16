import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../../services/flight_api_service.dart';
import 'upload_ticket_service.dart';
import '../../screens/home/flight_results_screen.dart';
import '../../screens/home/flight_select_screen.dart';
import 'controller/add_flight_controller.dart';

class Airport {
  final String city;
  final String airport;
  final String iata;
  final String countryCode;
  final String countryName;

  Airport({
    required this.city,
    required this.airport,
    required this.iata,
    this.countryCode = '',
    this.countryName = '',
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      city: json['city'] ?? '',
      airport: json['airport'] ?? '',
      iata: json['iata'] ?? '',
    );
  }

  factory Airport.fromApiJson(Map<String, dynamic> json) {
    return Airport(
      city: json['city'] ?? '',
      airport: json['airport'] ?? '',
      iata: json['iata_code'] ?? '',
      countryCode: json['country_code'] ?? '',
      countryName: json['country_name'] ?? '',
    );
  }

  String get displayName {
    // If airport name is the same as city, just show city with IATA
    if (airport.toLowerCase() == city.toLowerCase()) {
      return '$city ($iata)';
    }
    
    // If airport name contains city name, show the full airport name
    if (airport.toLowerCase().contains(city.toLowerCase())) {
      return '$city ($iata) – $airport';
    }
    
    // Otherwise show city and airport separately
    return '$city ($iata) – $airport';
  }
}

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedDepartureCity;
  String? _selectedArrivalCity;
  Airport? _selectedDepartureAirport;
  Airport? _selectedArrivalAirport;
  
  List<Airport> _allAirports = [];
  bool _isLoadingAirports = false;

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAirports() async {
    setState(() {
      _isLoadingAirports = true;
    });

    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/airports_global.json');
      
      final List<dynamic> jsonList = json.decode(jsonString);
      
      setState(() {
        _allAirports = jsonList.map((json) => Airport.fromJson(json)).toList();
        _isLoadingAirports = false;
      });
      
      print('Loaded ${_allAirports.length} airports');
      if (_allAirports.isNotEmpty) {
        print('Sample airport: ${_allAirports.first.displayName}');
      }
    } catch (e) {
      print('Error loading airports: $e');
      setState(() {
        _isLoadingAirports = false;
      });
    }
  }

  Future<List<Airport>> _getAirportSuggestions(String query) async {

    final lowercaseQuery = query.toLowerCase();
    final List<Airport> filtered = [];
    
    for (final airport in _allAirports) {
      final cityLower = airport.city.toLowerCase();
      final airportLower = airport.airport.toLowerCase();
      final iataLower = airport.iata.toLowerCase();
      
      bool matches = false;
      
      // Exact IATA code match (highest priority)
      if (iataLower == lowercaseQuery) {
        matches = true;
      }
      // IATA code starts with query
      else if (iataLower.startsWith(lowercaseQuery)) {
        matches = true;
      }
      // City name starts with query
      else if (cityLower.startsWith(lowercaseQuery)) {
        matches = true;
      }
      // Airport name starts with query
      else if (airportLower.startsWith(lowercaseQuery)) {
        matches = true;
      }
      // Contains query in any field
      else if (cityLower.contains(lowercaseQuery) || 
               airportLower.contains(lowercaseQuery) || 
               iataLower.contains(lowercaseQuery)) {
        matches = true;
      }
      
      if (matches) {
        filtered.add(airport);
      }
    }
    
    // Sort by relevance and take top 8
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
    
    // Exact IATA code match (highest priority)
    if (iataLower == query) return 1000;
    
    // IATA code starts with query
    if (iataLower.startsWith(query)) return 900;
    
    // City name starts with query
    if (cityLower.startsWith(query)) return 800;
    
    // Airport name starts with query
    if (airportLower.startsWith(query)) return 700;
    
    // Contains query in any field
    if (cityLower.contains(query) || airportLower.contains(query) || iataLower.contains(query)) {
      return 100;
    }
    
    return 0;
  }

  /// Get popular airports for empty field suggestions
  List<Airport> _getPopularAirports() {
    final popularIataCodes = [
      'JFK', 'LAX', 'LHR', 'CDG', 'DEL', 'BOM', 'SIN', 'HKG', 'DXB', 'FRA',
      'AMS', 'MAD', 'BCN', 'MIA', 'ORD', 'ATL', 'DFW', 'DEN', 'SFO', 'SEA'
    ];
    
    final List<Airport> popularAirports = [];
    for (final iata in popularIataCodes) {
      final airport = _allAirports.where((a) => a.iata == iata).firstOrNull;
      if (airport != null) {
        popularAirports.add(airport);
      }
    }
    
    return popularAirports;
  }

  /// Show popular airports when field is tapped and empty
  void _showPopularAirports(BuildContext context, TextEditingController controller, Function(Airport) onSelected) {
    // This will be handled by the suggestionsCallback when pattern is empty
    // The TypeAheadField will automatically show suggestions
  }
  
  /// Extract IATA code from airport display text
  /// Examples:
  /// "Delhi (DEL) – Indira Gandhi International Airport" → "DEL"
  /// "New York (JFK)" → "JFK"
  String _extractIataCode(String displayText) {
    // Look for pattern like "(XXX)" where XXX is the IATA code
    final regex = RegExp(r'\(([A-Z]{3})\)');
    final match = regex.firstMatch(displayText);
    if (match != null) {
      return match.group(1) ?? '';
    }
    
    // If no match found, return the original text (fallback)
    print('⚠️ Could not extract IATA code from: $displayText');
    return displayText;
  }

  void _onDepartureAirportSelected(Airport airport) {
    final controller = context.read<AddFlightController>();
    controller.onDepartureAirportSelected(airport);
  }

  void _onArrivalAirportSelected(Airport airport) {
    final controller = context.read<AddFlightController>();
    controller.onArrivalAirportSelected(airport);
  }

  bool get _isFormValid {
    final controller = context.read<AddFlightController>();
    return controller.isFormValid;
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1F2937),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF1F2937),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final controller = context.read<AddFlightController>();
      controller.setSelectedDate(picked);
    }
  }

  Future<void> _searchFlights() async {
    final controller = context.read<AddFlightController>();
    
    // Use the selected airport objects directly
    if (controller.selectedDepartureAirport == null || controller.selectedArrivalAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both departure and arrival airports'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    
    final departureIata = controller.selectedDepartureAirport!.iata;
    final arrivalIata = controller.selectedArrivalAirport!.iata;
    
    print('🔍 Search: $departureIata → $arrivalIata');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightSelectScreen(
          searchFuture: FlightApiService.searchFlights(
            departureIata: departureIata,
            arrivalIata: arrivalIata,
            date: DateFormat('yyyy-MM-dd').format(controller.selectedDate!),
            flightNumber: controller.flightNumberController.text.isNotEmpty ? controller.flightNumberController.text : null,
          ),
          departureCity: controller.departureCityController.text.trim(),
          arrivalCity: controller.arrivalCityController.text.trim(),
          date: DateFormat('yyyy-MM-dd').format(controller.selectedDate!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Flight',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24), // More space below title
                      // --- Smart Options: Upload Ticket / Scan Pass ---
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await UploadTicketService.uploadTicket(
                                    context,
                                    onSuccess: _populateFormFromTicket,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.05),
                                  elevation: 1,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.upload, color: Color(0xFF4B5563), size: 16),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Upload Ticket',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.2,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: OutlinedButton(
                                onPressed: () async {
                                  try {
                                    final result = await UploadTicketService.scanPass(
                                      context,
                                      onSuccess: _populateFormFromTicket,
                                    );
                                    print('Scan Pass result: $result');
                                  } catch (e) {
                                    print('Scan Pass error: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to scan ticket: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.05),
                                  elevation: 1,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.camera_alt, color: Color(0xFF4B5563), size: 16),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Scan Pass',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        height: 1.2,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // --- Helper text ---
                      SizedBox(
                        width: 330,
                        child: Text(
                          "We'll automatically extract flight details from your ticket or boarding pass.",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.33,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      // --- Divider with 'or enter manually' ---
                      SizedBox(
                        width: 350,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Color(0xFFD1D5DB),
                                thickness: 1,
                                endIndent: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: const Text(
                                'or enter manually',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.33,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Color(0xFFD1D5DB),
                                thickness: 1,
                                indent: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Consumer<AddFlightController>(
                        builder: (context, controller, child) {
                          return _buildTypeAheadField(
                            label: 'From',
                            icon: Icons.flight_takeoff,
                            controller: controller.departureCityController,
                            hintText: 'Search city or airport code',
                            onSelected: _onDepartureAirportSelected,
                            isLoading: _isLoadingAirports,
                            isAirportSelected: controller.selectedDepartureAirport != null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer<AddFlightController>(
                        builder: (context, controller, child) {
                          return _buildTypeAheadField(
                            label: 'To',
                            icon: Icons.flight_land,
                            controller: controller.arrivalCityController,
                            hintText: 'Search city or airport code',
                            onSelected: _onArrivalAirportSelected,
                            isLoading: _isLoadingAirports,
                            isAirportSelected: controller.selectedArrivalAirport != null,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDateField(),
                      const SizedBox(height: 24),
                      Consumer<AddFlightController>(
                        builder: (context, controller, child) {
                          return _buildLabeledField(
                            label: 'Flight Number (Optional)',
                            optional: true,
                            icon: Icons.flight,
                            controller: controller.flightNumberController,
                            hintText: 'e.g. UA1234',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Helper text for flight number and general guidance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Flight number helps us find exact matches.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Consumer<AddFlightController>(
                builder: (context, controller, child) {
                  return SizedBox(
                    width: 350,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isFormValid
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _searchFlights();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.search, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Find Flights',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeAheadField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    required Function(Airport) onSelected,
    required bool isLoading,
    required bool isAirportSelected, // New parameter to track if airport is selected
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
            Text(' *',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TypeAheadField<Airport>(
          controller: controller,
          hideOnEmpty: true, // Hide suggestions when empty to prevent "No items found"
          builder: (context, controller, focusNode) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFFADAEBC),
                  ),
                  prefixIcon: Icon(icon, color: Color(0xFF9CA3AF), size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                            ),
                          ),
                        ),
                      // Success indicator (green checkmark)
                      if (isAirportSelected && !isLoading)
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                      // Dropdown indicator
                      Container(
                        margin: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: isAirportSelected ? Color(0xFF10B981) : Color(0xFF9CA3AF),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
                onTap: () {
                  // Show suggestions when field is tapped
                  if (controller.text.isEmpty) {
                    // If empty, show popular airports
                    _showPopularAirports(context, controller, onSelected);
                  }
                },
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            // Only show suggestions if user has typed at least 1 character
            if (pattern.length < 1) {
              return [];
            }
            return await _getAirportSuggestions(pattern);
          },
          itemBuilder: (context, Airport airport) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                airport.displayName,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: airport.airport.toLowerCase() != airport.city.toLowerCase()
                  ? Text(
                      airport.airport,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    )
                  : null,
            );
          },
          onSelected: (Airport airport) {
            onSelected(airport);
          },
        ),
        // Helper text for fields that need attention
        if (!isAirportSelected && controller.text.isNotEmpty && !isLoading) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF6B7280),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Please select a specific airport',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    bool optional = false,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
            if (optional)
              Text(' (Optional)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            if (!optional)
              Text(' *',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(icon, color: Color(0xFF9CA3AF), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFFADAEBC),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Date',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
            Text(' *',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, color: Color(0xFF9CA3AF), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<AddFlightController>(
                    builder: (context, controller, child) {
                      return Text(
                        controller.selectedDate != null
                            ? DateFormat('MMM dd, yyyy').format(controller.selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: controller.selectedDate != null ? Color(0xFF1F2937) : Color(0xFFADAEBC),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Find airport object by city name and IATA code (only exact matches)
  Airport? _findAirportByCityAndIata(String city, String iata) {
    final normalizedCity = city.toLowerCase().trim();
    final normalizedIata = iata.toUpperCase().trim();
    
    developer.log('AddFlightScreen: Looking for airport - City: "$city", IATA: "$iata"', name: 'VoloUpload');
    
    // Only try exact matches - no auto-selection for city names
    for (final airport in _allAirports) {
      final airportCity = airport.city.toLowerCase().trim();
      final airportIata = airport.iata.toUpperCase().trim();
      
      // Check if city and IATA code match exactly
      if (airportCity == normalizedCity && airportIata == normalizedIata) {
        developer.log('AddFlightScreen: Found exact match: ${airport.displayName}', name: 'VoloUpload');
        return airport;
      }
    }
    
    developer.log('AddFlightScreen: Could not find exact airport match for $city ($iata)', name: 'VoloUpload');
    return null;
  }

  /// Populate form fields from extracted ticket data
  void _populateFormFromTicket(Map<String, dynamic> ticketData) {
    try {
      final controller = context.read<AddFlightController>();
      
      // Extract flight number
      final String? flightNumber = ticketData['flightNumber'] as String?;
      if (flightNumber != null && flightNumber.isNotEmpty) {
        controller.flightNumberController.text = flightNumber;
      }

      // Extract and set departure date
      final String? departureDateStr = ticketData['departureDate'] as String?;
      if (departureDateStr != null) {
        final DateTime? parsedDate = DateTime.tryParse(departureDateStr);
        if (parsedDate != null) {
          controller.setSelectedDate(parsedDate);
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
          final Airport? departureAirportObj = _findAirportByCityAndIata(departureCity, departureAirport);
          if (departureAirportObj != null) {
            // Use the airport object to populate (same as dropdown selection)
            _onDepartureAirportSelected(departureAirportObj);
            developer.log('AddFlightScreen: Found departure airport: ${departureAirportObj.displayName}', name: 'VoloUpload');
          } else {
            // Valid IATA but not found in database, pre-populate with city name
            controller.departureCityController.text = departureCity;
            controller.selectedDepartureCity = departureCity;
            controller.selectedDepartureAirport = null; // Clear airport object since we only have city name
            controller.notifyListeners();
            developer.log('AddFlightScreen: Pre-populated departure with city: $departureCity (IATA not found)', name: 'VoloUpload');
          }
        } else {
          // Not a valid IATA code, pre-populate with city name only
          controller.departureCityController.text = departureCity;
          controller.selectedDepartureCity = departureCity;
          controller.selectedDepartureAirport = null; // Clear airport object since we only have city name
          controller.notifyListeners();
          developer.log('AddFlightScreen: Pre-populated departure with city: $departureCity (not valid IATA)', name: 'VoloUpload');
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
          final Airport? arrivalAirportObj = _findAirportByCityAndIata(arrivalCity, arrivalAirport);
          if (arrivalAirportObj != null) {
            // Use the airport object to populate (same as dropdown selection)
            _onArrivalAirportSelected(arrivalAirportObj);
            developer.log('AddFlightScreen: Found arrival airport: ${arrivalAirportObj.displayName}', name: 'VoloUpload');
          } else {
            // Valid IATA but not found in database, pre-populate with city name
            controller.arrivalCityController.text = arrivalCity;
            controller.selectedArrivalCity = arrivalCity;
            controller.selectedArrivalAirport = null; // Clear airport object since we only have city name
            controller.notifyListeners();
            developer.log('AddFlightScreen: Pre-populated arrival with city: $arrivalCity (IATA not found)', name: 'VoloUpload');
          }
        } else {
          // Not a valid IATA code, pre-populate with city name only
          controller.arrivalCityController.text = arrivalCity;
          controller.selectedArrivalCity = arrivalCity;
          controller.selectedArrivalAirport = null; // Clear airport object since we only have city name
          controller.notifyListeners();
          developer.log('AddFlightScreen: Pre-populated arrival with city: $arrivalCity (not valid IATA)', name: 'VoloUpload');
        }
      }

      developer.log('AddFlightScreen: Form populated with ticket data: $ticketData', name: 'VoloUpload');
    } catch (e) {
      developer.log('AddFlightScreen: Error populating form from ticket data: $e', name: 'VoloUpload');
    }
  }
} 