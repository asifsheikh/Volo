import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
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
  List<Airport> _filteredDepartureAirports = [];
  List<Airport> _filteredArrivalAirports = [];
  Timer? _departureDebounceTimer;
  Timer? _arrivalDebounceTimer;
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
    _departureDebounceTimer?.cancel();
    _arrivalDebounceTimer?.cancel();
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

  void _filterDepartureAirports(String query) {
    if (query.length < 2) {
      setState(() {
        _filteredDepartureAirports = [];
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = _allAirports.where((airport) {
      return airport.city.toLowerCase().contains(lowercaseQuery) ||
             airport.airport.toLowerCase().contains(lowercaseQuery) ||
             airport.iata.toLowerCase().contains(lowercaseQuery);
    }).take(8).toList();

    setState(() {
      _filteredDepartureAirports = filtered;
    });
  }

  void _filterArrivalAirports(String query) {
    if (query.length < 2) {
      setState(() {
        _filteredArrivalAirports = [];
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = _allAirports.where((airport) {
      return airport.city.toLowerCase().contains(lowercaseQuery) ||
             airport.airport.toLowerCase().contains(lowercaseQuery) ||
             airport.iata.toLowerCase().contains(lowercaseQuery);
    }).take(8).toList();

    setState(() {
      _filteredArrivalAirports = filtered;
    });
  }

  void _onDepartureCityChanged(String value) {
    _departureDebounceTimer?.cancel();
    _departureDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterDepartureAirports(value);
    });
  }

  void _onArrivalCityChanged(String value) {
    _arrivalDebounceTimer?.cancel();
    _arrivalDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _filterArrivalAirports(value);
    });
  }

  void _onDepartureAirportSelected(Airport airport) {
    setState(() {
      _departureCityController.text = airport.displayName;
      _selectedDepartureCity = airport.displayName;
      _filteredDepartureAirports = [];
    });
  }

  void _onArrivalAirportSelected(Airport airport) {
    setState(() {
      _arrivalCityController.text = airport.displayName;
      _selectedArrivalCity = airport.displayName;
      _filteredArrivalAirports = [];
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
    final departureCode = _departureCityController.text.trim();
    final arrivalCode = _arrivalCityController.text.trim();
    if (departureCode.isEmpty || arrivalCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both departure and arrival cities'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightSelectScreen(
          searchFuture: FlightApiService.searchFlights(
            departureIata: departureCode,
            arrivalIata: arrivalCode,
            date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
            flightNumber: _flightNumberController.text.isNotEmpty ? _flightNumberController.text : null,
          ),
          departureCity: departureCode,
          arrivalCity: arrivalCode,
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
                      const SizedBox(height: 8),
                      _buildLabeledField(
                        label: 'Flight Number',
                        optional: true,
                        icon: Icons.flight,
                        controller: _flightNumberController,
                        hintText: 'e.g. UA4',
                      ),
                      const SizedBox(height: 24),
                      _buildDateField(),
                      const SizedBox(height: 24),
                      _buildAutocompleteField(
                        label: 'Departure City',
                        icon: Icons.flight_takeoff,
                        controller: _departureCityController,
                        hintText: 'Delhi (DEL)',
                        suggestions: _filteredDepartureAirports,
                        onChanged: _onDepartureCityChanged,
                        onSelected: _onDepartureAirportSelected,
                        isLoading: _isLoadingAirports,
                      ),
                      const SizedBox(height: 24),
                      _buildAutocompleteField(
                        label: 'Arrival City',
                        icon: Icons.flight_land,
                        controller: _arrivalCityController,
                        hintText: 'Berlin (BER)',
                        suggestions: _filteredArrivalAirports,
                        onChanged: _onArrivalCityChanged,
                        onSelected: _onArrivalAirportSelected,
                        isLoading: _isLoadingAirports,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enter city names or airport codes. Flight number helps us find exact matches.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF6B7280),
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
                        'Search Flights',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
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

  Widget _buildAutocompleteField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    required List<Airport> suggestions,
    required ValueChanged<String> onChanged,
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
        Stack(
          children: [
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
            if (suggestions.isNotEmpty)
              Positioned(
                top: 58,
                left: 0,
                right: 0,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final airport = suggestions[index];
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
                        onTap: () => onSelected(airport),
                      );
                    },
                  ),
                ),
              ),
          ],
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
              'Departure Date',
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
                Icon(Icons.calendar_today, color: Color(0xFF9CA3AF), size: 16),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMMM d, yyyy').format(_selectedDate!)
                        : 'Departure Date',
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

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Color(0xFF1F2937) : Color(0xFF9CA3AF), size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: isActive ? Color(0xFF1F2937) : Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
} 