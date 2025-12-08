import 'package:flutter/material.dart';
import '../../../widgets/onboarding/selection_card.dart';

class AgeStep extends StatelessWidget {
  final String? selectedAge;
  final Function(String) onAgeSelected;

  const AgeStep({
    super.key,
    required this.selectedAge,
    required this.onAgeSelected,
  });

  static const List<String> ageGroups = [
    '13-17',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
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
            'Yaş grubunuz nedir?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Deneyiminizi kişiselleştirmemize yardımcı olur.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Age options
          Expanded(
            child: ListView.separated(
              itemCount: ageGroups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final age = ageGroups[index];
                return SelectionCard(
                  text: age,
                  isSelected: selectedAge == age,
                  onTap: () => onAgeSelected(age),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
