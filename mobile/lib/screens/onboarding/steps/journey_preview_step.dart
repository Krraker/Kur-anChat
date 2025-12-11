import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../styles/styles.dart';

class JourneyPreviewStep extends StatelessWidget {
  final String? language;
  
  const JourneyPreviewStep({super.key, this.language});

  bool get isEnglish => language == 'en';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Allah icon
          SvgPicture.asset(
            'assets/icons/allah_icon.svg',
            width: 120,
            height: 120,
            colorFilter: ColorFilter.mode(
              GlobalAppStyle.accentColor,
              BlendMode.srcIn,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            isEnglish ? 'Begin Your Faith Journey' : 'İman Yolculuğunuza Başlayın',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            isEnglish 
                ? 'We\'re here to help you strengthen your faith and overcome life\'s challenges.'
                : 'İmanınızı güçlendirmenize ve zorluklarla başa çıkmanıza yardımcı olmak için buradayız.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats bar with glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(Icons.calendar_today, isEnglish ? '7 Days' : '7 Gün'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildStatItem(Icons.access_time, isEnglish ? '< 5 min/day' : '< 5 dk/gün'),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Journey cards
          _buildJourneyCard(
            day: 1,
            title: isEnglish ? 'Start with Reflection' : 'Tefekkür ile Başla',
            description: isEnglish ? 'Begin your day with the verse and prayer.' : 'Günün ayeti ve dua ile güne başlayın.',
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
          ),
          
          _buildDottedLine(),
          
          _buildJourneyCard(
            day: 2,
            title: isEnglish ? 'Deepen Your Understanding' : 'Anlayışını Derinleştir',
            description: isEnglish ? 'Explore tafsir and wisdom.' : 'Tefsir ve hikmetleri keşfedin.',
            icon: Icons.psychology,
            iconColor: Colors.blue,
          ),
          
          _buildDottedLine(),
          
          _buildJourneyCard(
            day: 3,
            title: isEnglish ? 'Focus on Consistency' : 'İstikrara Odaklan',
            description: isEnglish ? 'Build a daily habit.' : 'Günlük alışkanlık oluşturun.',
            icon: Icons.trending_up,
            iconColor: Colors.green,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard({
    required int day,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'DAY $day' : 'GÜN $day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDottedLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 41),
      child: SizedBox(
        height: 30,
        child: CustomPaint(
          painter: DottedLinePainter(),
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
