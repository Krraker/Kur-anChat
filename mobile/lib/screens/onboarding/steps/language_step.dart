import 'dart:ui';
import 'package:flutter/material.dart';

class LanguageStep extends StatelessWidget {
  final String? selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageStep({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  static const List<Map<String, String>> languageOptions = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷', 'native': 'Türkçe'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸', 'native': 'English'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦', 'native': 'Arabic'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪', 'native': 'German'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷', 'native': 'French'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩', 'native': 'Indonesian'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰', 'native': 'Urdu'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩', 'native': 'Bengali'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾', 'native': 'Malay'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺', 'native': 'Russian'},
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
            'Choose your language',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle in multiple languages
          Text(
            'Dilinizi seçin • اختر لغتك',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Language options
          Expanded(
            child: ListView.separated(
              itemCount: languageOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final language = languageOptions[index];
                return _LanguageCard(
                  flag: language['flag']!,
                  name: language['name']!,
                  nativeName: language['native']!,
                  isSelected: selectedLanguage == language['code'],
                  onTap: () => onLanguageSelected(language['code']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String flag;
  final String name;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag,
    required this.name,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected 
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ]
                    : [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.15),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag
                Text(
                  flag,
                  style: const TextStyle(fontSize: 28),
                ),
                
                const SizedBox(width: 16),
                
                // Language name
                Expanded(
                  child: Text(
                        name,
                        style: TextStyle(
                      fontSize: 17,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.white.withOpacity(isSelected ? 1 : 0.9),
                        ),
                  ),
                ),
                
                // Checkmark
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A86B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
