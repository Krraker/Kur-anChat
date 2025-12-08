import 'package:flutter/material.dart';
import '../../screens/main_navigation.dart';
import '../../styles/styles.dart';

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
              return LiquidGlassChip(
                onTap: () {
                  // Switch to chat tab
                  final navController = NavigationProvider.maybeOf(context);
                  navController?.goToChat();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      topic['icon'] as IconData,
                      color: GlobalAppStyle.accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      topic['title'] as String,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
