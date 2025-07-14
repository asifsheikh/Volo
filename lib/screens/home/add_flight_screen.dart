import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../services/flight_api_service.dart';
import 'flight_results_screen.dart';
import 'flight_select_screen.dart';

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
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureCityController = TextEditingController();
  final TextEditingController _arrivalCityController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedDepartureCity;
  String? _selectedArrivalCity;
  
  List<Airport> _allAirports = [];
  bool _isLoadingAirports = false;

  @override
  void initState() {
    super.initState();
    _loadAirports();
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _departureCityController.dispose();
    _arrivalCityController.dispose();
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
    setState(() {
      _departureCityController.text = airport.displayName;
      _selectedDepartureCity = airport.displayName;
    });
  }

  void _onArrivalAirportSelected(Airport airport) {
    setState(() {
      _arrivalCityController.text = airport.displayName;
      _selectedArrivalCity = airport.displayName;
    });
  }

  bool get _isFormValid {
    return _selectedDate != null &&
        _selectedDepartureCity != null &&
        _selectedArrivalCity != null;
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _searchFlights() async {
    // Extract IATA codes from the selected airports
    final departureIata = _extractIataCode(_departureCityController.text.trim());
    final arrivalIata = _extractIataCode(_arrivalCityController.text.trim());
    
    if (departureIata.isEmpty || arrivalIata.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both departure and arrival cities'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    
    print('🔍 Search: $departureIata → $arrivalIata');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightSelectScreen(
          searchFuture: FlightApiService.searchFlights(
            departureIata: departureIata,
            arrivalIata: arrivalIata,
            date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
            flightNumber: _flightNumberController.text.isNotEmpty ? _flightNumberController.text : null,
          ),
          departureCity: _departureCityController.text.trim(),
          arrivalCity: _arrivalCityController.text.trim(),
          date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
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
                      SizedBox(
                        width: 350,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 169,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {},
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
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 169,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {},
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
                          ],
                        ),
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
                      _buildLabeledField(
                        label: 'Flight Number (Optional)',
                        optional: true,
                        icon: Icons.flight,
                        controller: _flightNumberController,
                        hintText: 'e.g. UA1234',
                      ),
                      const SizedBox(height: 24),
                      _buildDateField(),
                      const SizedBox(height: 24),
                      _buildTypeAheadField(
                        label: 'From',
                        icon: Icons.flight_takeoff,
                        controller: _departureCityController,
                        hintText: 'Search city or airport code',
                        onSelected: _onDepartureAirportSelected,
                        isLoading: _isLoadingAirports,
                      ),
                      const SizedBox(height: 24),
                      _buildTypeAheadField(
                        label: 'To',
                        icon: Icons.flight_land,
                        controller: _arrivalCityController,
                        hintText: 'Search city or airport code',
                        onSelected: _onArrivalAirportSelected,
                        isLoading: _isLoadingAirports,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Flight number helps us find exact matches. You can search by city name or airport code (like DEL for Delhi).',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid
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
          hideOnEmpty: true,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFFADAEBC),
                ),
                prefixIcon: Icon(icon, color: Color(0xFF9CA3AF), size: 20),
                suffixIcon: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                          ),
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1F2937), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            // Only show suggestions if user has typed at least 2 characters
            if (pattern.length < 2) {
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
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: _selectedDate != null ? Color(0xFF1F2937) : Color(0xFFADAEBC),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 