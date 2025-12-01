import 'message.dart';

class Conversation {
  final String id;
  final String userId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message>? messages;

  Conversation({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}


