import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../services/flight_api_service.dart';
import 'upload_ticket_service.dart';
import '../../screens/home/flight_results_screen.dart';
import '../../screens/home/flight_select_screen.dart';
import '../../features/flight_confirmation/screens/confirmation_screen.dart' show resetConfettiForNewJourney;
import 'presentation/providers/add_flight_provider.dart';
import 'domain/entities/airport_entity.dart';
import 'domain/entities/flight_entity.dart';

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

class AddFlightScreen extends ConsumerStatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends ConsumerState<AddFlightScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedDepartureCity;
  String? _selectedArrivalCity;
  AirportEntity? _selectedDepartureAirport;
  AirportEntity? _selectedArrivalAirport;

  // Animation controllers for micro-interactions
  late AnimationController _uploadButtonController;
  late AnimationController _scanButtonController;
  late Animation<double> _uploadButtonScale;
  late Animation<double> _scanButtonScale;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _uploadButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scanButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _uploadButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _uploadButtonController, curve: Curves.easeInOut),
    );
    _scanButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scanButtonController, curve: Curves.easeInOut),
    );
    
    // Reset confetti flag for new journey
    resetConfettiForNewJourney();
    
    // Reset confetti flag for new journey
    resetConfettiForNewJourney();
  }

  @override
  void dispose() {
    _uploadButtonController.dispose();
    _scanButtonController.dispose();
    super.dispose();
  }

  /// Get popular airports for empty field suggestions
  List<AirportEntity> _getPopularAirports(List<AirportEntity> allAirports) {
    final popularIataCodes = [
      'JFK', 'LAX', 'LHR', 'CDG', 'DEL', 'BOM', 'SIN', 'HKG', 'DXB', 'FRA',
      'AMS', 'MAD', 'BCN', 'MIA', 'ORD', 'ATL', 'DFW', 'DEN', 'SFO', 'SEA'
    ];
    
    final List<AirportEntity> popularAirports = [];
    for (final iata in popularIataCodes) {
      final airport = allAirports.where((a) => a.iata == iata).firstOrNull;
      if (airport != null) {
        popularAirports.add(airport);
      }
    }
    
    return popularAirports;
  }

  /// Show popular airports when field is tapped and empty
  void _showPopularAirports(BuildContext context, TextEditingController controller, Function(AirportEntity) onSelected) {
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

  void _onDepartureAirportSelected(AirportEntity airport) {
    setState(() {
      _selectedDepartureAirport = airport;
      _selectedDepartureCity = airport.city;
    });
  }

  void _onArrivalAirportSelected(AirportEntity airport) {
    setState(() {
      _selectedArrivalAirport = airport;
      _selectedArrivalCity = airport.city;
    });
  }

  bool get _isFormValid {
    return _selectedDepartureAirport != null && 
           _selectedArrivalAirport != null && 
           _selectedDate != null;
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
    // Use the selected airport objects directly
    if (_selectedDepartureAirport == null || _selectedArrivalAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both departure and arrival airports to continue'),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Got it',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }
    
    final departureIata = _selectedDepartureAirport!.iata;
    final arrivalIata = _selectedArrivalAirport!.iata;
    
    print('🔍 Search: $departureIata → $arrivalIata');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightSelectScreen(
          searchFuture: FlightApiService.searchFlights(
            departureIata: departureIata,
            arrivalIata: arrivalIata,
            date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
            flightNumber: '', // TODO: Add flight number field
          ),
          departureCity: _selectedDepartureCity ?? '',
          arrivalCity: _selectedArrivalCity ?? '',
          date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
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
                            child: AnimatedBuilder(
                              animation: _uploadButtonScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _uploadButtonScale.value,
                                  child: SizedBox(
                                    height: 58,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        _uploadButtonController.forward().then((_) {
                                          _uploadButtonController.reverse();
                                        });
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
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _scanButtonScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scanButtonScale.value,
                                  child: SizedBox(
                                    height: 58,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        _scanButtonController.forward().then((_) {
                                          _scanButtonController.reverse();
                                        });
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
                                              content: Text('Unable to scan ticket. Please try uploading it instead.'),
                                              backgroundColor: Colors.orange,
                                              duration: const Duration(seconds: 4),
                                              action: SnackBarAction(
                                                label: 'Upload',
                                                textColor: Colors.white,
                                                onPressed: () async {
                                                  await UploadTicketService.uploadTicket(
                                                    context,
                                                    onSuccess: _populateFormFromTicket,
                                                  );
                                                },
                                              ),
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
                                );
                              },
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
                      Consumer(
                        builder: (context, ref, child) {
                          final airports = ref.watch(airportsProvider);
                          final isLoading = ref.watch(addFlightLoadingProvider);
                          return _buildTypeAheadField(
                            label: 'From',
                            icon: Icons.flight_takeoff,
                            controller: TextEditingController(text: _selectedDepartureCity ?? ''),
                            hintText: 'Search city or airport code',
                            onSelected: _onDepartureAirportSelected,
                            isLoading: isLoading,
                            isAirportSelected: _selectedDepartureAirport != null,
                            airports: airports,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer(
                        builder: (context, ref, child) {
                          final airports = ref.watch(airportsProvider);
                          final isLoading = ref.watch(addFlightLoadingProvider);
                          return _buildTypeAheadField(
                            label: 'To',
                            icon: Icons.flight_land,
                            controller: TextEditingController(text: _selectedArrivalCity ?? ''),
                            hintText: 'Search city or airport code',
                            onSelected: _onArrivalAirportSelected,
                            isLoading: isLoading,
                            isAirportSelected: _selectedArrivalAirport != null,
                            airports: airports,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDateField(),
                      const SizedBox(height: 24),
                      _buildLabeledField(
                        label: 'Flight Number (Optional)',
                        optional: true,
                        icon: Icons.flight,
                        controller: TextEditingController(),
                        hintText: 'e.g. UA1234',
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
              child: Consumer(
                builder: (context, ref, child) {
                  final isFormValid = _isFormValid;
                  return SizedBox(
                    width: 350,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isFormValid
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                _searchFlights();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059393),
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
    required Function(AirportEntity) onSelected,
    required bool isLoading,
    required bool isAirportSelected, // New parameter to track if airport is selected
    required List<AirportEntity> airports,
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
            TypeAheadField<AirportEntity>(
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
                if (pattern.isEmpty) {
                  return _getPopularAirports(airports);
                }
                return airports.where((airport) =>
                  airport.city.toLowerCase().contains(pattern.toLowerCase()) ||
                  airport.airport.toLowerCase().contains(pattern.toLowerCase()) ||
                  airport.iata.toLowerCase().contains(pattern.toLowerCase())
                ).toList();
              },
              itemBuilder: (context, AirportEntity airport) {
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
              onSelected: (AirportEntity airport) {
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
      },
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

  /// Populate form fields from extracted ticket data
  void _populateFormFromTicket(Map<String, dynamic> ticketData) {
    // TODO: Implement ticket data population
    // This would populate the form fields with extracted data
  }
} 