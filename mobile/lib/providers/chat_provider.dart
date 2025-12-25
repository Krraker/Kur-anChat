import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AnalyticsService _analytics = AnalyticsService();

  ChatProvider({required ApiService apiService}) : _apiService = apiService;

  final List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  String? _error;
  
  // ⭐ NEW: Usage tracking
  ChatUsage? _usage;
  bool _limitReached = false;

  List<Message> get messages => List.unmodifiable(_messages);
  String? get conversationId => _conversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatUsage? get usage => _usage;
  bool get limitReached => _limitReached;
  
  // Helper getters
  bool get isPremium => _usage?.isPremium ?? false;
  String get remainingMessagesText => _usage?.displayText ?? '';
  int get remainingMessages => _usage?.remainingMessages ?? 3;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_limitReached) return; // ⭐ Don't send if limit reached

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
      
      // ⭐ Update usage info
      _usage = response.usage;
      _limitReached = false;

      // ⭐ Track analytics
      if (_usage != null) {
        _analytics.logChatMessageSent(
          messageLength: text.length,
          isPremium: _usage!.isPremium,
        );
        
        // Warn if approaching limit (1 message left)
        if (_usage!.remainingMessages == 1 && !_usage!.isPremium) {
          _analytics.logChatLimitWarning(remainingMessages: 1);
        }
      }

      // Add assistant response
      final assistantMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sender: MessageSender.assistant,
        content: response.response,
        createdAt: DateTime.now(),
      );

      _messages.add(assistantMessage);
      
    } on MessageLimitException catch (e) {
      // ⭐ Handle limit reached
      _limitReached = true;
      _error = 'Günlük 3 mesaj limitine ulaştınız. ${e.resetTimeText} yeniden deneyin.';
      
      // Remove the user message that couldn't be sent
      _messages.removeLast();
      
      // ⭐ Track analytics
      _analytics.logChatLimitReached(messagesSent: 3);
      
      debugPrint('🚫 Message limit reached: ${e.toString()}');
      
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
    _limitReached = false; // ⭐ Reset limit state
    notifyListeners();
  }
  
  // ⭐ NEW: Reset limit reached state (for when user upgrades to premium)
  void resetLimitState() {
    _limitReached = false;
    _error = null;
    notifyListeners();
  }
}


