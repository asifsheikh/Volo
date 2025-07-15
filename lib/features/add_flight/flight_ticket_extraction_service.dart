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

      return result;

    } catch (e) {
      print('Error extracting flight info: $e');
      return null;
    }
  }

  /// Create structured prompt for ticket extraction
  String _createTicketExtractionPrompt() {
    return '''
You are an expert at analyzing flight tickets and boarding passes.
Analyze the provided flight ticket/document and extract the following information.

IMPORTANT: Return ONLY a valid JSON object with the following structure:
{
  "isValidTicket": true/false, // Set to true if all required fields are found and valid, otherwise false.
  "flightNumber": "string (e.g., UA1234, AA5678, QR001)",
  "departureDate": "YYYY-MM-DD format (e.g., 2024-01-15)",
  "departureCity": "string (e.g., New York, London, Tokyo)",
  "departureAirport": "string (3-letter IATA code, e.g., JFK, LHR, NRT)",
  "arrivalCity": "string (e.g., Los Angeles, Paris, Dubai)",
  "arrivalAirport": "string (3-letter IATA code, e.g., LAX, CDG, DXB)"
}

If any information is not found or is unclear, return an empty string for that field, and set "isValidTicket" to false.
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

    // Check for required fields and their non-empty values
    final requiredFields = [
      'flightNumber',
      'departureDate', 
      'departureCity',
      'departureAirport',
      'arrivalCity',
      'arrivalAirport'
    ];

    for (final field in requiredFields) {
      if (data[field] == null || data[field].toString().trim().isEmpty) {
        print('Required field "' + field + '" is missing or empty.');
        return false;
      }
    }

    // Validate date format
    try {
      DateTime.parse(data['departureDate'].toString().trim());
    } catch (e) {
      print('Invalid date format for departureDate: ${data['departureDate']}');
      return false;
    }

    // Validate airport codes (should be 3 uppercase letters)
    RegExp iataCodePattern = RegExp(r'^[A-Z]{3}$');
    if (!iataCodePattern.hasMatch(data['departureAirport'].toString().toUpperCase()) || 
        !iataCodePattern.hasMatch(data['arrivalAirport'].toString().toUpperCase())) {
      print('Invalid airport code format. Expected 3 uppercase letters.');
      return false;
    }

    return true;
  }
} 