import 'quran_verse.dart';

enum MessageSender { user, assistant }

class Message {
  final String id;
  final MessageSender sender;
  final MessageContent content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final senderStr = json['sender'] as String;
    final sender = senderStr == 'user' 
        ? MessageSender.user 
        : MessageSender.assistant;

    final content = sender == MessageSender.user
        ? UserMessageContent.fromJson(json['content'])
        : AssistantMessageContent.fromJson(json['content']);

    return Message(
      id: json['id'] as String,
      sender: sender,
      content: content,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

abstract class MessageContent {}

class UserMessageContent extends MessageContent {
  final String text;

  UserMessageContent({required this.text});

  factory UserMessageContent.fromJson(Map<String, dynamic> json) {
    return UserMessageContent(
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text};
  }
}

class AssistantMessageContent extends MessageContent {
  final String summary;
  final List<QuranVerse> verses;
  final String disclaimer;

  AssistantMessageContent({
    required this.summary,
    required this.verses,
    required this.disclaimer,
  });

  factory AssistantMessageContent.fromJson(Map<String, dynamic> json) {
    return AssistantMessageContent(
      summary: json['summary'] as String,
      verses: (json['verses'] as List)
          .map((v) => QuranVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'verses': verses.map((v) => v.toJson()).toList(),
      'disclaimer': disclaimer,
    };
  }
}


