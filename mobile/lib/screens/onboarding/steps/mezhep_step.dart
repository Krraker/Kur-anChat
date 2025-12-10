import 'package:flutter/material.dart';
import '../../../widgets/onboarding/selection_card.dart';

class MezhepStep extends StatelessWidget {
  final String? selectedMezhep;
  final Function(String) onMezhepSelected;
  final String? language;

  const MezhepStep({
    super.key,
    required this.selectedMezhep,
    required this.onMezhepSelected,
    this.language,
  });

  bool get isEnglish => language == 'en';

  List<Map<String, String>> get mezhepOptions => [
    {'name': 'Hanafi', 'desc': isEnglish ? 'Most common in Turkey' : 'Türkiye\'de en yaygın mezhep'},
    {'name': 'Shafi\'i', 'desc': isEnglish ? 'Common in Southeast Asia' : 'Güneydoğu Anadolu ve Kürt bölgelerinde yaygın'},
    {'name': 'Maliki', 'desc': isEnglish ? 'Common in North Africa' : 'Kuzey Afrika\'da yaygın'},
    {'name': 'Hanbali', 'desc': isEnglish ? 'Common in Saudi Arabia' : 'Suudi Arabistan\'da yaygın'},
    {'name': 'Ja\'fari', 'desc': isEnglish ? 'Shia Islam school' : 'Şii İslam mezhebi'},
    {'name': isEnglish ? 'Non-denominational / Other' : 'Mezhepsiz / Diğer', 'desc': isEnglish ? 'I don\'t follow a specific school' : 'Belirli bir mezhebe bağlı değilim'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isEnglish ? 'What\'s your Islamic school of thought?' : 'Mezhebinizi belirtir misiniz?',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            isEnglish ? 'This helps us provide relevant resources.' : 'Size uygun kaynakları sunmamıza yardımcı olur.',
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
