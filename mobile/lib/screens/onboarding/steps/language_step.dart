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
    {'code': 'tr', 'name': 'Türkçe', 'flag': 'TR', 'native': 'Türkçe'},
    {'code': 'en', 'name': 'English', 'flag': 'EN', 'native': 'English'},
    {'code': 'ar', 'name': 'العربية', 'flag': 'AR', 'native': 'Arabic'},
    {'code': 'de', 'name': 'Deutsch', 'flag': 'DE', 'native': 'German'},
    {'code': 'fr', 'name': 'Français', 'flag': 'FR', 'native': 'French'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': 'ID', 'native': 'Indonesian'},
    {'code': 'ur', 'name': 'اردو', 'flag': 'PK', 'native': 'Urdu'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': 'BD', 'native': 'Bengali'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': 'MY', 'native': 'Malay'},
    {'code': 'ru', 'name': 'Русский', 'flag': 'RU', 'native': 'Russian'},
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
                // Flag code badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    flag,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
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
