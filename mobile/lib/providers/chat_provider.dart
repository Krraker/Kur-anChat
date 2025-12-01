import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;

  ChatProvider({required ApiService apiService}) : _apiService = apiService;

  final List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => List.unmodifiable(_messages);
  String? get conversationId => _conversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Clear previous error
    _error = null;
    notifyListeners();

    // Add user message immediately
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      content: UserMessageContent(text: text),
      createdAt: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Add a small delay for better UX (simulating "thinking")
      await Future.delayed(const Duration(milliseconds: 800));

      // Send to backend
      final response = await _apiService.sendMessage(
        message: text,
        conversationId: _conversationId,
      );

      // Add another small delay before showing the response
      await Future.delayed(const Duration(milliseconds: 600));

      // Update conversation ID if new
      _conversationId ??= response.conversationId;

      // Add assistant response
      final assistantMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: MessageSender.assistant,
        content: response.response,
        createdAt: DateTime.now(),
      );

      _messages.add(assistantMessage);
    } catch (e) {
      _error = e.toString();
      
      // Add error message
      final errorMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: MessageSender.assistant,
        content: AssistantMessageContent(
          summary: 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
          verses: [],
          disclaimer: 'Sunucuya bağlanırken bir sorun yaşandı.',
        ),
        createdAt: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _conversationId = null;
    _error = null;
    notifyListeners();
  }
}


