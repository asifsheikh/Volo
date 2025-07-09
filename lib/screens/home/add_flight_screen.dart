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
    print('Filtering departure airports for query: "$query"');
    print('Total airports available: ${_allAirports.length}');
    
    if (query.length < 3) {
      setState(() {
        _filteredDepartureAirports = [];
      });
      print('Query too short, clearing results');
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = _allAirports.where((airport) {
      return airport.city.toLowerCase().contains(lowercaseQuery) ||
             airport.airport.toLowerCase().contains(lowercaseQuery) ||
             airport.iata.toLowerCase().contains(lowercaseQuery);
    }).take(10).toList();

    print('Found ${filtered.length} matching departure airports');
    if (filtered.isNotEmpty) {
      print('First result: ${filtered.first.displayName}');
    }

    setState(() {
      _filteredDepartureAirports = filtered;
    });
    print('Dropdown should show: ${_filteredDepartureAirports.isNotEmpty}');
    print('Filtered departure airports count: ${_filteredDepartureAirports.length}');
  }

  void _filterArrivalAirports(String query) {
    print('Filtering arrival airports for query: "$query"');
    print('Total airports available: ${_allAirports.length}');
    
    if (query.length < 3) {
      setState(() {
        _filteredArrivalAirports = [];
      });
      print('Query too short, clearing results');
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filtered = _allAirports.where((airport) {
      return airport.city.toLowerCase().contains(lowercaseQuery) ||
             airport.airport.toLowerCase().contains(lowercaseQuery) ||
             airport.iata.toLowerCase().contains(lowercaseQuery);
    }).take(10).toList();

    print('Found ${filtered.length} matching arrival airports');
    if (filtered.isNotEmpty) {
      print('First result: ${filtered.first.displayName}');
    }

    setState(() {
      _filteredArrivalAirports = filtered;
    });
    print('Dropdown should show: ${_filteredArrivalAirports.isNotEmpty}');
    print('Filtered arrival airports count: ${_filteredArrivalAirports.length}');
  }

  void _onDepartureCityChanged(String value) {
    print('Departure City changed to: "$value"');
    _departureDebounceTimer?.cancel();
    _departureDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('Debounce timer fired, filtering for: "$value"');
      _filterDepartureAirports(value);
    });
  }

  void _onArrivalCityChanged(String value) {
    print('Arrival City changed to: "$value"');
    _arrivalDebounceTimer?.cancel();
    _arrivalDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('Debounce timer fired, filtering for: "$value"');
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Enter your flight details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF808080),
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('✈️ ', style: TextStyle(fontSize: 16)),
                        const Text(
                          'Flight Number',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '(Optional)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _flightNumberController,
                      decoration: InputDecoration(
                        hintText: 'UA4',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFFADAEBC),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFF1F2937)),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final regex = RegExp(r'^[A-Z]{2,3} ?\d{1,4} 0$');
                          if (!regex.hasMatch(value.trim().toUpperCase())) {
                            return 'Invalid flight number';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('📅 ', style: TextStyle(fontSize: 16)),
                        const Text(
                          'Departure Date',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Select date',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Color(0xFFADAEBC),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Color(0xFF1F2937)),
                            ),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                                : '',
                          ),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('🛫 ', style: TextStyle(fontSize: 16)),
                        const Text(
                          'Departure City',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _departureCityController,
                      decoration: InputDecoration(
                        hintText: 'Enter departure city or code',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFFADAEBC),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFF1F2937)),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartureCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('📍 ', style: TextStyle(fontSize: 16)),
                        const Text(
                          'Arrival City',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _arrivalCityController,
                      decoration: InputDecoration(
                        hintText: 'Enter arrival city or code',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFFADAEBC),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFF1F2937)),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Color(0xFF1F2937),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedArrivalCity = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _searchFlights();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Search Flights',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 