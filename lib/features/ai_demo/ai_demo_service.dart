import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class AIDemoService {
  static final AIDemoService _instance = AIDemoService._internal();
  factory AIDemoService() => _instance;
  AIDemoService._internal();

  GenerativeModel? _model;

  /// Initialize the AI demo service with a specific model and App Check instance
  Future<void> initialize({String modelName = 'gemini-2.5-flash', FirebaseAppCheck? appCheck}) async {
    try {
      // Initialize the Gemini Developer API backend service with App Check
      _model = FirebaseAI.googleAI(appCheck: appCheck).generativeModel(model: modelName);
      print('AI Demo Service initialized with model: $modelName');
    } catch (e) {
      print('Error initializing AI demo service: $e');
      rethrow;
    }
  }

  /// Generate text content from a prompt
  Future<String?> generateText(String prompt) async {
    if (_model == null) {
      await initialize(appCheck: FirebaseAppCheck.instance);
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
      await initialize(appCheck: FirebaseAppCheck.instance);
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

  /// Start a chat conversation
  Future<ChatSession> startChat() async {
    if (_model == null) {
      await initialize(appCheck: FirebaseAppCheck.instance);
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