import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GenerativeModel? _model;

  /// Initialize the AI service with a specific model and App Check instance
  Future<void> initialize({String modelName = 'gemini-2.5-flash', FirebaseAppCheck? appCheck}) async {
    try {
      // Initialize the Gemini Developer API backend service with App Check
      _model = FirebaseAI.googleAI(appCheck: appCheck).generativeModel(model: modelName);
      print('AI Service initialized with model: $modelName');
    } catch (e) {
      print('Error initializing AI service: $e');
      rethrow;
    }
  }

  /// Generate text content from a prompt
  Future<String?> generateText(String prompt) async {
    if (_model == null) {
      await initialize();
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error generating text: $e');
      return null;
    }
  }

  /// Generate text with streaming response
  Stream<String> generateTextStream(String prompt) async* {
    if (_model == null) {
      await initialize();
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContentStream(content);
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      print('Error generating streaming text: $e');
      yield 'Error: $e';
    }
  }

  /// Generate structured output (JSON) from a prompt
  /*
  Future<Map<String, dynamic>?> generateStructuredOutput(
    String prompt, 
    Map<String, dynamic> schema
  ) async {
    if (_model == null) {
      await initialize();
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(
        content,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          // responseSchema: Schema.fromJson(schema), // Not available in this version
        ),
      );
      
      // Parse the JSON response
      if (response.text != null) {
        return Map<String, dynamic>.from(
          // You might need to parse the JSON string here
          // depending on how the response is formatted
          response.text as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      print('Error generating structured output: $e');
      return null;
    }
  }
  */

  /// Analyze an image and generate text description
  /*
  Future<String?> analyzeImage(String imageUrl, String prompt) async {
    if (_model == null) {
      await initialize();
    }

    try {
      final content = [
        Content.text(prompt),
        Content.data(Data.fromUrl(imageUrl), mimeType: 'image/jpeg'),
      ];
      
      final response = await _model!.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error analyzing image: $e');
      return null;
    }
  }
  */

  /// Start a chat conversation
  ChatSession startChat() {
    if (_model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }
    return _model!.startChat();
  }

  /// Send a message in a chat session
  Future<String?> sendChatMessage(ChatSession chat, String message) async {
    try {
      final response = await chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      print('Error sending chat message: $e');
      return null;
    }
  }
} 