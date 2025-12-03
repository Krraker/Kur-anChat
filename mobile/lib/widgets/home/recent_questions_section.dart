import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../screens/chat_screen.dart';
import '../../styles/styles.dart';

class RecentQuestionsSection extends StatelessWidget {
  const RecentQuestionsSection({super.key});

  // Placeholder recent questions - will be replaced with actual chat history
  static const placeholderQuestions = [
    'Faiz (riba) hakkında ayetler nelerdir?',
    'Sabır hakkında ayetler göster',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Son Sorular',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            // Get user messages from chat history
            final userMessages = chatProvider.messages
                .where((msg) => msg.sender.toString().contains('user'))
                .toList();
            
            // Use actual messages if available, otherwise use placeholders
            final questions = userMessages.isNotEmpty
                ? userMessages.reversed.take(3).map((msg) {
                    final content = msg.content;
                    if (content.toString().contains('UserMessageContent')) {
                      return 'Recent question';
                    }
                    return 'Recent question';
                  }).toList()
                : placeholderQuestions;
            
            if (questions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LiquidGlassListItem(
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Henüz soru sormadınız',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length > 3 ? 3 : questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final question = questions[index];
                return LiquidGlassListItem(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: GlobalAppStyle.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
