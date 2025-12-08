import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quran_verse.dart';
import '../styles/styles.dart';

class VerseCard extends StatelessWidget {
  final QuranVerse verse;

  const VerseCard({
    super.key,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Traditional Quran paper - aged parchment color
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F0E3), // Light aged parchment
            Color(0xFFF5ECD8), // Slightly darker cream
            Color(0xFFF2E8D0), // Warm aged paper
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: const Border(
          left: BorderSide(
            color: GlobalAppStyle.accentColor, // Islamic green
            width: 4,
          ),
        ),
        // Subtle paper-like shadow
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7355).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle paper texture overlay (decorative corner)
          Positioned(
            right: 8,
            top: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: GlobalAppStyle.accentColor.withOpacity(0.15),
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surah and Ayah reference badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GlobalAppStyle.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GlobalAppStyle.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    verse.surahName != null
                        ? '${verse.surahName} Suresi, ${verse.ayah}. Ayet'
                        : '${verse.surah}:${verse.ayah}',
                    style: TextStyle(
                      color: GlobalAppStyle.accentColor.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Arabic text - Elegant Quranic style
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFD4C4A8).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    verse.textAr,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 26,
                      height: 2.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1408), // Deep brown/black for Arabic
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Turkish translation - Elegant italic
                Text(
                  verse.textTr,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF4A4035), // Warm brown text
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
