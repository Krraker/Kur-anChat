import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/conversation.dart';
import 'auth_service.dart';
import 'api_config.dart';

class ApiService {
  final http.Client _client = http.Client();

  /// Get headers including auth headers
  Map<String, String> _getHeaders() {
    final authHeaders = AuthService().getAuthHeaders();
    return {
      'Content-Type': 'application/json',
      ...authHeaders,
    };
  }

  /// Register device with backend (creates user if not exists)
  Future<Map<String, dynamic>?> registerDevice() async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/user/register-device'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Save user ID from response
        if (data['userId'] != null) {
          await AuthService().setUserId(data['userId']);
        }
        
        return data;
      } else {
        debugPrint('Failed to register device: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error registering device: $e');
      return null;
    }
  }

  Future<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final userId = AuthService().userId ?? AuthService().deviceId ?? 'anonymous';
      
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/chat'),
        headers: _getHeaders(),
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

  Future<List<Conversation>> getConversations() async {
    try {
      final userId = AuthService().userId ?? AuthService().deviceId ?? 'anonymous';
      
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/conversations?userId=$userId'),
        headers: _getHeaders(),
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
        Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId'),
        headers: _getHeaders(),
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

  /// Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          'GET $endpoint failed: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          'POST $endpoint failed: ${response.statusCode}',
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
