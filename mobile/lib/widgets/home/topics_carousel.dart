import 'dart:ui';
import 'package:flutter/material.dart';
import '../../screens/chat_screen.dart';

class TopicsCarousel extends StatelessWidget {
  const TopicsCarousel({super.key});

  // Sample topics - can be replaced with dynamic data
  static const topics = [
    {'title': 'Sabır', 'icon': Icons.favorite_border},
    {'title': 'Tevekkül', 'icon': Icons.self_improvement},
    {'title': 'Merhamet', 'icon': Icons.volunteer_activism},
    {'title': 'Ahlak', 'icon': Icons.lightbulb_outline},
    {'title': 'İbadet', 'icon': Icons.mosque},
    {'title': 'Adalet', 'icon': Icons.balance},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bugün keşfedebilirsiniz',
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
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topics.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _TopicChip(
                title: topic['title'] as String,
                icon: topic['icon'] as IconData,
                onTap: () {
                  // Navigate to chat with pre-filled prompt about this topic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                  // TODO: Pre-fill chat with topic-specific question
                  // e.g., "Show me verses about ${topic['title']}"
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _TopicChip({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF7FE79C).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF7FE79C),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

