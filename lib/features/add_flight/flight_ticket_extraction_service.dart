import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:typed_data';
import 'dart:convert';

class FlightTicketExtractionService {
  static final FlightTicketExtractionService _instance = FlightTicketExtractionService._internal();
  factory FlightTicketExtractionService() => _instance;
  FlightTicketExtractionService._internal();

  GenerativeModel? _model;

  /// Initialize the AI service with a specific model and App Check instance
  Future<void> initialize({String modelName = 'gemini-2.5-flash', FirebaseAppCheck? appCheck}) async {
    try {
      _model = FirebaseAI.googleAI(appCheck: appCheck).generativeModel(
        model: modelName,
      );
      print('Flight Ticket Extraction Service initialized with model: $modelName');
    } catch (e) {
      print('Error initializing flight ticket extraction service: $e');
      rethrow;
    }
  }

  /// Extract flight information from uploaded ticket (image or PDF)
  Future<Map<String, dynamic>?> extractFlightInfo(Uint8List fileData, String fileName) async {
    if (_model == null) {
      await initialize(appCheck: FirebaseAppCheck.instance);
    }

    try {
      // Determine file type and create appropriate prompt
      final String fileExtension = fileName.toLowerCase().split('.').last;
      String mimeType;
      if (["jpg", "jpeg"].contains(fileExtension)) {
        mimeType = 'image/jpeg';
      } else if (fileExtension == 'png') {
        mimeType = 'image/png';
      } else if (fileExtension == 'pdf') {
        mimeType = 'application/pdf';
      } else {
        throw Exception('Unsupported file type. Please upload a JPG, PNG, or PDF file.');
      }

      // Create an InlineDataPart from your file data
      final InlineDataPart filePart = InlineDataPart(mimeType, fileData);
      final String promptText = _createTicketExtractionPrompt();

      // Combine the text prompt and the file data into a multi-part content
      final List<Content> content = [
        Content.multi([TextPart(promptText), filePart])
      ];

      // Generate response
      final response = await _model!.generateContent(content);
      
      if (response.text == null) {
        throw Exception('No text response from AI service. Model might have been blocked or returned no text.');
      }

      // Parse JSON response
      final Map<String, dynamic> result = _parseAIResponse(response.text!);
      
      // Validate extracted data
      if (!_isValidTicketData(result)) {
        throw Exception('Invalid ticket or missing required information based on AI response.');
      }

      // Remove duplicate flights (e.g., same flight for multiple passengers)
      final Map<String, dynamic> deduplicatedResult = _removeDuplicateFlights(result);

      return deduplicatedResult;

    } catch (e) {
      print('Error extracting flight info: $e');
      return null;
    }
  }

  /// Create structured prompt for ticket extraction
  String _createTicketExtractionPrompt() {
    return '''
You are an expert at analyzing flight tickets and boarding passes.
Analyze the provided flight ticket/document and extract ALL flight information.

IMPORTANT: Return ONLY a valid JSON object with the following structure:
{
  "isValidTicket": true/false,
  "ticketType": "one-way" | "round-trip" | "multi-city",
  "flights": [
    {
      "flightNumber": "string (e.g., UA1234, AA5678, QR001)",
      "departureDate": "YYYY-MM-DD format (e.g., 2024-01-15)",
      "departureCity": "string (e.g., New York, London, Tokyo)",
      "departureAirport": "string (3-letter IATA code, e.g., JFK, LHR, NRT) - if no airport code is visible, use the city name",
      "arrivalCity": "string (e.g., Los Angeles, Paris, Dubai)",
      "arrivalAirport": "string (3-letter IATA code, e.g., LAX, CDG, DXB) - if no airport code is visible, use the city name",
      "isLayover": true/false,
      "layoverCity": "string (if applicable, e.g., Dubai, Frankfurt)"
    }
  ]
}

IMPORTANT RULES:
1. For ONE-WAY tickets with layovers (e.g., Delhi → Dubai → London):
   - Extract only the FIRST departure and FINAL arrival airports
   - Mark intermediate stops as layovers
   - Example: Delhi → London (with layover in Dubai)

2. For ROUND-TRIP tickets (e.g., Delhi → London → Delhi):
   - Extract BOTH legs as separate flights
   - First leg: Delhi → London
   - Second leg: London → Delhi

3. For MULTI-CITY tickets:
   - Extract each leg as a separate flight

4. Airport codes:
   - If you see a 3-letter airport code (like JFK, LHR, DEL), use that
   - If you only see city names without airport codes, use the city name
   - For major cities, you can infer common airport codes (e.g., New York → JFK, London → LHR, Delhi → DEL)

5. DEDUPLICATION: If you see the same flight information repeated multiple times (e.g., for multiple passengers on the same flight), only include each unique flight once. Focus on unique flight routes, not passenger-specific details.

6. If any information is not found or is unclear, return an empty string for that field, and set "isValidTicket" to false.

Return ONLY the JSON object, no additional text or explanations.
''';
  }

  /// Parse AI response and extract JSON
  Map<String, dynamic> _parseAIResponse(String response) {
    try {
      // Clean the response - remove any markdown formatting
      String cleanResponse = response.trim();
      
      // Remove markdown code blocks if present
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      
      cleanResponse = cleanResponse.trim();
      
      // Parse JSON
      return json.decode(cleanResponse);
    } catch (e) {
      print('Error parsing AI response: $e. Response was: "$response"');
      throw Exception('Failed to parse AI response. Check if the model returned valid JSON.');
    }
  }

  /// Validate extracted ticket data
  bool _isValidTicketData(Map<String, dynamic> data) {
    // Check if it's marked as valid ticket by the model's output
    if (data['isValidTicket'] != true) {
      print('Model indicated isValidTicket is false or not present.');
      return false;
    }

    // Check for required fields
    if (data['ticketType'] == null || data['flights'] == null) {
      print('Missing required fields: ticketType or flights');
      return false;
    }

    // Validate flights array
    final List<dynamic> flights = data['flights'];
    if (flights.isEmpty) {
      print('No flights found in the ticket');
      return false;
    }

    // Validate each flight
    for (int i = 0; i < flights.length; i++) {
      final flight = flights[i];
      if (flight is! Map<String, dynamic>) {
        print('Flight $i is not a valid object');
        return false;
      }

      // Check for required fields in each flight
      final requiredFields = [
        'flightNumber',
        'departureDate', 
        'departureCity',
        'departureAirport',
        'arrivalCity',
        'arrivalAirport'
      ];

      for (final field in requiredFields) {
        if (flight[field] == null || flight[field].toString().trim().isEmpty) {
          print('Required field "$field" is missing or empty in flight $i');
          return false;
        }
      }

      // Validate date format
      try {
        DateTime.parse(flight['departureDate'].toString().trim());
      } catch (e) {
        print('Invalid date format for departureDate in flight $i: ${flight['departureDate']}');
        return false;
      }

      // Validate airport codes (can be 3 uppercase letters OR city names)
      final departureAirport = flight['departureAirport'].toString().trim();
      final arrivalAirport = flight['arrivalAirport'].toString().trim();
      
      // Check if they are valid IATA codes (3 uppercase letters)
      RegExp iataCodePattern = RegExp(r'^[A-Z]{3}$');
      final isDepartureValidIata = iataCodePattern.hasMatch(departureAirport.toUpperCase());
      final isArrivalValidIata = iataCodePattern.hasMatch(arrivalAirport.toUpperCase());
      
      // If not valid IATA codes, they should be city names (not empty and reasonable length)
      if (!isDepartureValidIata && (departureAirport.isEmpty || departureAirport.length < 2)) {
        print('Invalid departure airport format in flight $i. Expected 3-letter IATA code or city name.');
        return false;
      }
      
      if (!isArrivalValidIata && (arrivalAirport.isEmpty || arrivalAirport.length < 2)) {
        print('Invalid arrival airport format in flight $i. Expected 3-letter IATA code or city name.');
        return false;
      }
      
      print('Flight $i validation: Departure="$departureAirport" (valid IATA: $isDepartureValidIata), Arrival="$arrivalAirport" (valid IATA: $isArrivalValidIata)');
    }

    return true;
  }

  /// Get the first flight for one-way tickets with layovers
  Map<String, dynamic>? getFirstFlight(Map<String, dynamic> ticketData) {
    if (ticketData['flights'] == null || ticketData['flights'].isEmpty) {
      return null;
    }

    final List<dynamic> flights = ticketData['flights'];
    final String ticketType = ticketData['ticketType'] ?? 'one-way';

    if (ticketType == 'one-way') {
      // For one-way tickets, return the first flight (handles layovers automatically)
      return Map<String, dynamic>.from(flights.first);
    }

    return null;
  }

  /// Get all flights for round-trip or multi-city tickets
  List<Map<String, dynamic>> getAllFlights(Map<String, dynamic> ticketData) {
    if (ticketData['flights'] == null || ticketData['flights'].isEmpty) {
      return [];
    }

    final List<dynamic> flights = ticketData['flights'];
    return flights.map((flight) => Map<String, dynamic>.from(flight)).toList();
  }

  /// Check if ticket has multiple selectable flights
  bool hasMultipleFlights(Map<String, dynamic> ticketData) {
    final String ticketType = ticketData['ticketType'] ?? 'one-way';
    final List<dynamic> flights = ticketData['flights'] ?? [];
    
    return (ticketType == 'round-trip' || ticketType == 'multi-city') && flights.length > 1;
  }

  /// Remove duplicate flights from the extracted data
  Map<String, dynamic> _removeDuplicateFlights(Map<String, dynamic> ticketData) {
    if (ticketData['flights'] == null) {
      return ticketData;
    }

    final List<dynamic> originalFlights = ticketData['flights'];
    final List<Map<String, dynamic>> uniqueFlights = [];
    final Set<String> seenFlightKeys = {};

    for (final flight in originalFlights) {
      if (flight is! Map<String, dynamic>) continue;

      // Create a unique key for this flight based on route and date
      final String flightKey = _createFlightKey(flight);
      
      if (!seenFlightKeys.contains(flightKey)) {
        seenFlightKeys.add(flightKey);
        uniqueFlights.add(Map<String, dynamic>.from(flight));
        print('Flight extraction: Added unique flight - $flightKey');
      } else {
        print('Flight extraction: Skipped duplicate flight - $flightKey');
      }
    }

    // Create new result with deduplicated flights
    final Map<String, dynamic> result = Map<String, dynamic>.from(ticketData);
    result['flights'] = uniqueFlights;
    
    // Store original count for UI feedback
    if (originalFlights.length != uniqueFlights.length) {
      result['originalFlightCount'] = originalFlights.length;
    }
    
    print('Flight extraction: Deduplication complete. Original: ${originalFlights.length}, Unique: ${uniqueFlights.length}');
    
    return result;
  }

  /// Create a unique key for a flight based on route and date
  String _createFlightKey(Map<String, dynamic> flight) {
    final departureAirport = (flight['departureAirport'] ?? '').toString().trim().toUpperCase();
    final arrivalAirport = (flight['arrivalAirport'] ?? '').toString().trim().toUpperCase();
    final departureDate = (flight['departureDate'] ?? '').toString().trim();
    final flightNumber = (flight['flightNumber'] ?? '').toString().trim().toUpperCase();
    
    // Create key: DEPARTURE_ARRIVAL_DATE_FLIGHTNUMBER
    return '${departureAirport}_${arrivalAirport}_${departureDate}_${flightNumber}';
  }
} 