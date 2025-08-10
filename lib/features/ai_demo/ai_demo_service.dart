import '../../services/ai_service.dart';

class AIDemoService {
  static final AIDemoService _instance = AIDemoService._internal();
  factory AIDemoService() => _instance;
  AIDemoService._internal();

  final AIService _aiService = AIService();

  /// Initialize the AI demo service with a specific model and App Check instance
  Future<void> initialize({String modelName = 'gemini-2.5-flash', FirebaseAppCheck? appCheck}) async {
    try {
      // Initialize the AI service
      await _aiService.initialize(modelName: modelName, appCheck: appCheck);
      print('AI Demo Service initialized with model: $modelName');
    } catch (e) {
      print('Error initializing AI demo service: $e');
      rethrow;
    }
  }

  /// Generate text content from a prompt
  Future<String?> generateText(String prompt) async {
    try {
      return await _aiService.generateText(prompt);
    } catch (e) {
      print('Error generating text: $e');
      return null;
    }
  }

  /// Generate text with streaming response
  Stream<String> generateTextStream(String prompt) async* {
    try {
      yield* _aiService.generateTextStream(prompt);
    } catch (e) {
      print('Error generating streaming text: $e');
      yield 'Error: $e';
    }
  }

  /// Start a chat conversation
  Future<ChatSession> startChat() async {
    return await _aiService.startChat();
  }

  /// Send a message in a chat session
  Future<String?> sendChatMessage(ChatSession chat, String message) async {
    try {
      return await _aiService.sendChatMessage(chat, message);
    } catch (e) {
      print('Error sending chat message: $e');
      return null;
    }
  }
} 