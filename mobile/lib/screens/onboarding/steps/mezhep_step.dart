import 'package:flutter/material.dart';
import '../../../widgets/onboarding/selection_card.dart';

class MezhepStep extends StatelessWidget {
  final String? selectedMezhep;
  final Function(String) onMezhepSelected;

  const MezhepStep({
    super.key,
    required this.selectedMezhep,
    required this.onMezhepSelected,
  });

  static const List<Map<String, String>> mezhepOptions = [
    {'name': 'Hanefi', 'desc': 'Türkiye\'de en yaygın mezhep'},
    {'name': 'Şafii', 'desc': 'Güneydoğu Anadolu ve Kürt bölgelerinde yaygın'},
    {'name': 'Maliki', 'desc': 'Kuzey Afrika\'da yaygın'},
    {'name': 'Hanbeli', 'desc': 'Suudi Arabistan\'da yaygın'},
    {'name': 'Caferi', 'desc': 'Şii İslam mezhebi'},
    {'name': 'Mezhepsiz / Diğer', 'desc': 'Belirli bir mezhebe bağlı değilim'},
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
            'Mezhebinizi belirtir misiniz?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Size uygun kaynakları sunmamıza yardımcı olur.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Mezhep options
          Expanded(
            child: ListView.separated(
              itemCount: mezhepOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mezhep = mezhepOptions[index];
                return SelectionCard(
                  text: mezhep['name']!,
                  subtitle: mezhep['desc'],
                  isSelected: selectedMezhep == mezhep['name'],
                  onTap: () => onMezhepSelected(mezhep['name']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
