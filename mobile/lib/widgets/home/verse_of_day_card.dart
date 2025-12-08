import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual verse of the day from API/service
    // For now, using a placeholder verse
    const arabicText = 'إِنَّ مَعَ ٱلْعُسْرِ يُسْرًا';
    const translation = 'Muhakkak ki, her zorlukla birlikte bir kolaylık vardır.';
    const reference = 'İnşirah Suresi, 6. Ayet';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF0).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Color(0xFF22c55e),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Günün Ayeti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Arabic text
              Text(
                arabicText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 28,
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2416),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Translation
              const Text(
                translation,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF4B5563),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Reference and "View details" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      reference,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to verse details or open in chat
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF22c55e),
                    ),
                    label: const Text(
                      'Detaylar',
                      style: TextStyle(
                        color: Color(0xFF22c55e),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

