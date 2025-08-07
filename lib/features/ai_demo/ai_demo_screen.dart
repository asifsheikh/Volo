import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart' show ChatSession;
import 'ai_demo_service.dart';

class AIDemoScreen extends StatefulWidget {
  const AIDemoScreen({super.key});

  @override
  State<AIDemoScreen> createState() => _AIDemoScreenState();
}

class _AIDemoScreenState extends State<AIDemoScreen> {
  final AIDemoService _aiService = AIDemoService();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  
  String _generatedText = '';
  String _streamedText = '';
  bool _isGenerating = false;
  bool _isStreaming = false;
  
  ChatSession? _chatSession;
  List<Map<String, String>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _promptController.text = 'Write a short story about a magical flight.';
  }

  @override
  void dispose() {
    _promptController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _generateText() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedText = '';
    });

    try {
      final result = await _aiService.generateText(_promptController.text);
      setState(() {
        _generatedText = result ?? 'No response generated';
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _generatedText = 'Error: $e';
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateStreamingText() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isStreaming = true;
      _streamedText = '';
    });

    try {
      await for (final chunk in _aiService.generateTextStream(_promptController.text)) {
        setState(() {
          _streamedText += chunk;
        });
      }
    } catch (e) {
      setState(() {
        _streamedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isStreaming = false;
      });
    }
  }

  Future<void> _startChat() async {
    _chatSession = await _aiService.startChat();
    _chatHistory.clear();
    setState(() {});
  }

  Future<void> _sendChatMessage() async {
    if (_chatController.text.trim().isEmpty || _chatSession == null) return;

    final userMessage = _chatController.text;
    _chatController.clear();

    setState(() {
      _chatHistory.add({'role': 'user', 'message': userMessage});
    });

    try {
      final response = await _aiService.sendChatMessage(_chatSession!, userMessage);
      setState(() {
        _chatHistory.add({'role': 'assistant', 'message': response ?? 'No response'});
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'assistant', 'message': 'Error: $e'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase AI Logic Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text Generation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Generation',
                      style: AppTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your prompt',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isGenerating ? null : _generateText,
                            child: _isGenerating
                                ? const CircularProgressIndicator()
                                : const Text('Generate Text'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isStreaming ? null : _generateStreamingText,
                            child: _isStreaming
                                ? const CircularProgressIndicator()
                                : const Text('Stream Text'),
                          ),
                        ),
                      ],
                    ),
                    if (_generatedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Generated Text:',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: AppTheme.cardDecoration.copyWith(
                          color: AppTheme.background,
                        ),
                        child: Text(_generatedText),
                      ),
                    ],
                    if (_streamedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                                              Text(
                          'Streamed Text:',
                          style: AppTheme.titleMedium,
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: AppTheme.cardDecoration.copyWith(
                          color: AppTheme.background,
                        ),
                        child: Text(_streamedText),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chat Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chat Conversation',
                          style: AppTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: _startChat,
                          child: const Text('Start Chat'),
                        ),
                      ],
                    ),
                    if (_chatSession != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _chatHistory.length,
                          itemBuilder: (context, index) {
                            final message = _chatHistory[index];
                            final isUser = message['role'] == 'user';
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: isUser 
                                    ? MainAxisAlignment.end 
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isUser ? Colors.blue[100] : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(message['message'] ?? ''),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: const InputDecoration(
                                labelText: 'Type your message',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _sendChatMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _sendChatMessage,
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 