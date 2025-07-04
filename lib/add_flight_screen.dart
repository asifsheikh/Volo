import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _departureCityController = TextEditingController();
  String? _selectedAirline;
  DateTime? _selectedDate;
  String? _selectedCity;

  // Placeholder airline and city lists
  final List<String> _airlines = [
    'Air India', 'IndiGo', 'Emirates', 'Qatar Airways', 'Lufthansa', 'United Airlines', 'Delta', 'American Airlines', 'British Airways', 'Singapore Airlines',
  ];
  final List<String> _cities = [
    'Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Hyderabad', 'Kolkata', 'Dubai', 'London', 'New York', 'Singapore', 'Frankfurt', 'Doha', 'San Francisco',
  ];

  @override
  void dispose() {
    _flightNumberController.dispose();
    _departureCityController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _flightNumberController.text.isNotEmpty &&
        _selectedAirline != null &&
        _selectedDate != null &&
        _selectedCity != null;
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

  Future<List<String>> fetchCitySuggestions(String pattern) async {
    if (pattern.isEmpty) return [];
    final apiKey = '17eb294fc9mshdb67f348052c7bcp1ead09jsn2a7c9031a53f';
    final url = Uri.parse('https://wft-geo-db.p.rapidapi.com/v1/geo/cities?namePrefix=$pattern&limit=10&sort=-population');
    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List cities = data['data'];
        return cities.map<String>((city) {
          final cityName = city['name'] ?? '';
          final country = city['country'] ?? '';
          return country.isNotEmpty ? '$cityName, $country' : cityName;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, size: 28, color: Color(0xFF1F2937)),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Add Flight',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Enter your flight details',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF808080),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flight Number',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _flightNumberController,
                          decoration: InputDecoration(
                            hintText: 'AI 101',
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
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a flight number';
                            }
                            final regex = RegExp(r'^[A-Z]{2,3} ?\d{1,4} 0$');
                            if (!regex.hasMatch(value.trim().toUpperCase())) {
                              return 'Invalid flight number';
                            }
                            return null;
                          },
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Airline',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownSearch<String>(
                          items: _airlines,
                          selectedItem: _selectedAirline,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Select airline',
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
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: 'Search airline',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedAirline = value;
                            });
                          },
                          validator: (value) => value == null ? 'Please select an airline' : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Departure Date',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Select date',
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
                                text: _selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: Color(0xFF1F2937),
                              ),
                              validator: (_) => _selectedDate == null ? 'Please select a date' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Departure City',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TypeAheadField<String>(
                          controller: _departureCityController,
                          suggestionsCallback: fetchCitySuggestions,
                          itemBuilder: (context, String suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (String suggestion) {
                            _departureCityController.text = suggestion;
                            setState(() {
                              _selectedCity = suggestion;
                            });
                          },
                          builder: (context, textEditingController, focusNode) {
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Enter city',
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
                                  return 'Please select a city';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Track Flight button
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: SizedBox(
                  width: 342,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Handle flight tracking logic
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
                        Icon(Icons.info_outline, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Track Flight',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
} 