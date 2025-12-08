import 'package:flutter/material.dart';
import '../../../widgets/onboarding/selection_card.dart';

class GoalsStep extends StatelessWidget {
  final Set<String> selectedGoals;
  final Function(String) onGoalToggled;

  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
  });

  static const List<Map<String, dynamic>> goalOptions = [
    {'name': 'Kur\'an\'ı daha iyi anlamak', 'icon': Icons.auto_stories},
    {'name': 'Günlük manevi gelişim', 'icon': Icons.trending_up},
    {'name': 'Hayat zorluklarını aşmak', 'icon': Icons.psychology},
    {'name': 'Namaz ve ibadet bilgisi', 'icon': Icons.access_time},
    {'name': 'Aile ve ilişkiler', 'icon': Icons.people},
    {'name': 'İş ve kariyer rehberliği', 'icon': Icons.work},
    {'name': 'Huzur ve sükûnet bulmak', 'icon': Icons.self_improvement},
    {'name': 'İslami bilgimi artırmak', 'icon': Icons.school},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Kur\'an size nasıl yardımcı olabilir?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Birden fazla seçebilirsiniz.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Goal options
          Expanded(
            child: ListView.separated(
              itemCount: goalOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = goalOptions[index];
                final isSelected = selectedGoals.contains(goal['name']);
                return SelectionCard(
                  text: goal['name'] as String,
                  icon: goal['icon'] as IconData,
                  isSelected: isSelected,
                  onTap: () => onGoalToggled(goal['name'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
