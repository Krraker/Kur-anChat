import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quran_verse.dart';

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
        // Kuran kağıdı rengi - daha opak (ayetler net görünsün)
        color: const Color(0xFFFFFBF0).withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF22c55e).withOpacity(0.8),
            width: 4,
          ),
        ),
        // Hafif gölge
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Surah and Ayah reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              verse.surahName != null
                  ? '${verse.surahName} Suresi, ${verse.ayah}. Ayet'
                  : '${verse.surah}:${verse.ayah}',
              style: const TextStyle(
                color: Color(0xFF15803D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Arabic text - More cursive, elegant font
          Text(
            verse.textAr,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 24,
              height: 2.2,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D2416),
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Turkish translation - İtalik ve daha zarif
          Text(
            verse.textTr,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              fontStyle: FontStyle.italic, // İtalik yaptık
              color: Color(0xFF4B5563),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}


