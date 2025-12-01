import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/conversation.dart';

class ApiService {
  // Change this to your backend URL
  // For Android emulator use: http://10.0.2.2:3001/api
  // For iOS simulator use: http://localhost:3001/api
  // For physical device use your computer's IP: http://192.168.x.x:3001/api
  static const String baseUrl = 'http://localhost:3001/api';

  final http.Client _client = http.Client();

  Future<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
    String userId = 'demo-user',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          if (conversationId != null) 'conversationId': conversationId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw ApiException(
          'Failed to send message: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<List<Conversation>> getConversations({
    String userId = 'demo-user',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/conversations?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to get conversations: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<Conversation> getConversation(String conversationId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/conversations/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Conversation.fromJson(data);
      } else {
        throw ApiException(
          'Failed to get conversation: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ChatResponse {
  final String conversationId;
  final AssistantMessageContent response;

  ChatResponse({
    required this.conversationId,
    required this.response,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      conversationId: json['conversationId'] as String,
      response: AssistantMessageContent.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}


