import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';

/// Quran reading screen - placeholder implementation
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String selectedSurah = 'Fatiha';
  int selectedSurahNumber = 1;
  String selectedTranslation = 'Diyanet';

  // Sample verses for placeholder
  static const List<Map<String, dynamic>> sampleVerses = [
    {
      'number': 1,
      'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'translation': 'Rahmân ve Rahîm olan Allah\'ın adıyla.',
    },
    {
      'number': 2,
      'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'translation': 'Hamd, âlemlerin Rabbi Allah\'a mahsustur.',
    },
    {
      'number': 3,
      'arabic': 'الرَّحْمَٰنِ الرَّحِيمِ',
      'translation': 'Rahmân ve Rahîm\'dir O.',
    },
    {
      'number': 4,
      'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
      'translation': 'Din gününün tek sahibidir.',
    },
    {
      'number': 5,
      'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'translation': 'Ancak sana kulluk eder ve ancak senden yardım dileriz.',
    },
    {
      'number': 6,
      'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'translation': 'Bizi dosdoğru yola ilet.',
    },
    {
      'number': 7,
      'arabic': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      'translation': 'Kendilerine nimet verdiklerinin yoluna; gazaba uğrayanların ve sapıkların yoluna değil.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top gradient overlay with blur
                ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Profile Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    GlobalAppStyle.accentColor,
                                    GlobalAppStyle.accentColor.withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GlobalAppStyle.accentColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'K',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 14),
                            
                            // Title
                            Text(
                              'Kur\'an',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Search Icon
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              onPressed: () {},
                            ),
                            
                            // More options
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Surah selector chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Surah chip
                    _buildSelectorChip(
                      '$selectedSurah $selectedSurahNumber',
                      onTap: () => _showSurahSelector(),
                    ),
                    const SizedBox(width: 8),
                    // Translation chip
                    _buildSelectorChip(
                      selectedTranslation,
                      onTap: () => _showTranslationSelector(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Verses list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 200,
                  ),
                  itemCount: sampleVerses.length,
                  itemBuilder: (context, index) {
                    final verse = sampleVerses[index];
                    return _buildVerseItem(verse);
                  },
                ),
              ),
            ],
          ),
          
          // Bottom navigation controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous button
                  _buildNavButton(
                    Icons.chevron_left,
                    onTap: () {},
                  ),
                  
                  // Play/Audio button
                  _buildNavButton(
                    Icons.play_arrow,
                    isCenter: true,
                    onTap: () {},
                  ),
                  
                  // Next button
                  _buildNavButton(
                    Icons.chevron_right,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseItem(Map<String, dynamic> verse) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text row (RTL - verse number on right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl, // RTL layout
            children: [
              // Verse number (on the right for RTL)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: GlobalAppStyle.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${verse['number']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GlobalAppStyle.accentColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Arabic text (right-to-left, right-aligned)
              Expanded(
                child: Text(
                  verse['arabic'] as String,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Translation (left-to-right, left-aligned)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              verse['translation'] as String,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, {bool isCenter = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCenter ? 56 : 48,
        height: isCenter ? 56 : 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: isCenter ? 28 : 24,
          ),
        ),
      ),
    );
  }

  void _showSurahSelector() {
    // TODO: Implement surah selector bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sure Seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 114,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: GlobalAppStyle.accentColor.withOpacity(0.2),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: GlobalAppStyle.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      _getSurahName(index + 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        selectedSurahNumber = index + 1;
                        selectedSurah = _getSurahName(index + 1);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslationSelector() {
    // TODO: Implement translation selector
  }

  String _getSurahName(int number) {
    const surahNames = [
      'Fatiha', 'Bakara', 'Âl-i İmran', 'Nisa', 'Maide',
      'En\'am', 'A\'raf', 'Enfal', 'Tevbe', 'Yunus',
      'Hud', 'Yusuf', 'Ra\'d', 'İbrahim', 'Hicr',
      'Nahl', 'İsra', 'Kehf', 'Meryem', 'Taha',
      // ... simplified for placeholder
    ];
    if (number <= surahNames.length) {
      return surahNames[number - 1];
    }
    return 'Sure $number';
  }
}

