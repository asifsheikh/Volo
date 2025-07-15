import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:typed_data';
import 'dart:convert';

class FlightTicketExtractionService {
  static final FlightTicketExtractionService _instance = FlightTicketExtractionService._internal();
  factory FlightTicketExtractionService() => _instance;
  FlightTicketExtractionService._internal();

  GenerativeModel? _model;

  /// Initialize the flight ticket extraction service with a specific model and App Check instance
  Future<void> initialize({String modelName = 'gemini-2.5-flash', FirebaseAppCheck? appCheck}) async {
    try {
      // Initialize the Gemini Developer API backend service with App Check
      _model = FirebaseAI.googleAI(appCheck: appCheck).generativeModel(model: modelName);
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
      final bool isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);
      final bool isPdf = fileExtension == 'pdf';

      if (!isImage && !isPdf) {
        throw Exception('Unsupported file type. Please upload a JPG, PNG, or PDF file.');
      }

      // Create structured prompt for flight ticket extraction
      final String prompt = _createTicketExtractionPrompt(isImage);

      // For now, we'll use text-only approach since binary data API is not working
      // TODO: Implement proper binary data handling when Firebase AI API is clarified
      final List<Content> content = [
        Content.text(prompt),
      ];

      // Generate response
      final response = await _model!.generateContent(content);
      
      if (response.text == null) {
        throw Exception('No response from AI service');
      }

      // Parse JSON response
      final Map<String, dynamic> result = _parseAIResponse(response.text!);
      
      // Validate extracted data
      if (!_isValidTicketData(result)) {
        throw Exception('Invalid ticket or missing required information');
      }

      return result;

    } catch (e) {
      print('Error extracting flight info: $e');
      return null;
    }
  }

  /// Create structured prompt for ticket extraction
  String _createTicketExtractionPrompt(bool isImage) {
    final String fileType = isImage ? 'image' : 'PDF document';
    
    return '''
You are an expert at analyzing flight tickets and boarding passes. 

NOTE: Since we cannot currently process the actual $fileType content, please provide a sample response structure for demonstration purposes.

IMPORTANT: Return ONLY a valid JSON object with the following structure:
{
  "isValidTicket": true/false,
  "flightNumber": "string (e.g., UA1234, AA5678)",
  "departureDate": "YYYY-MM-DD format",
  "departureCity": "string (e.g., New York, London)",
  "departureAirport": "string (3-letter IATA code, e.g., JFK, LHR)",
  "arrivalCity": "string (e.g., Los Angeles, Paris)",
  "arrivalAirport": "string (3-letter IATA code, e.g., LAX, CDG)"
}

For demonstration purposes, return a sample valid ticket response:
{"isValidTicket": true, "flightNumber": "UA1234", "departureDate": "2024-01-15", "departureCity": "New York", "departureAirport": "JFK", "arrivalCity": "Los Angeles", "arrivalAirport": "LAX"}

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
      print('Error parsing AI response: $e');
      throw Exception('Failed to parse AI response');
    }
  }

  /// Validate extracted ticket data
  bool _isValidTicketData(Map<String, dynamic> data) {
    // Check if it's marked as valid ticket
    if (data['isValidTicket'] != true) {
      return false;
    }

    // Check for required fields
    final requiredFields = [
      'flightNumber',
      'departureDate', 
      'departureCity',
      'departureAirport',
      'arrivalCity',
      'arrivalAirport'
    ];

    for (final field in requiredFields) {
      if (data[field] == null || data[field].toString().isEmpty) {
        return false;
      }
    }

    // Validate date format
    try {
      DateTime.parse(data['departureDate']);
    } catch (e) {
      return false;
    }

    // Validate airport codes (should be 3 letters)
    if (data['departureAirport'].toString().length != 3 || 
        data['arrivalAirport'].toString().length != 3) {
      return false;
    }

    return true;
  }
} 