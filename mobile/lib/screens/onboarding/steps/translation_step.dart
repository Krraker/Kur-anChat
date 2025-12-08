import 'package:flutter/material.dart';
import '../../../widgets/onboarding/selection_card.dart';

class TranslationStep extends StatelessWidget {
  final String? selectedTranslation;
  final Function(String) onTranslationSelected;

  const TranslationStep({
    super.key,
    required this.selectedTranslation,
    required this.onTranslationSelected,
  });

  static const List<Map<String, String>> translationOptions = [
    {'name': 'Diyanet İşleri', 'desc': 'Resmi Diyanet meali'},
    {'name': 'Elmalılı Hamdi Yazır', 'desc': 'Klasik Osmanlı tefsiri'},
    {'name': 'Süleyman Ateş', 'desc': 'Modern akademik çeviri'},
    {'name': 'Yaşar Nuri Öztürk', 'desc': 'Çağdaş yorum'},
    {'name': 'Muhammed Esed', 'desc': 'Uluslararası tanınmış meal'},
    {'name': 'Bayraktar Bayraklı', 'desc': 'Yeni nesil tefsir'},
    {'name': 'Edip Yüksel', 'desc': 'Reformist çeviri'},
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
            'Tercih ettiğiniz Kur\'an meali?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'İstediğiniz zaman değiştirebilirsiniz.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Translation options
          Expanded(
            child: ListView.separated(
              itemCount: translationOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final translation = translationOptions[index];
                return SelectionCard(
                  text: translation['name']!,
                  subtitle: translation['desc'],
                  isSelected: selectedTranslation == translation['name'],
                  onTap: () => onTranslationSelected(translation['name']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
