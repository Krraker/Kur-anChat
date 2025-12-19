import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';
import '../services/api_config.dart';
import '../models/message.dart' show decodeHtmlEntities;

/// Quran reading screen - with API integration
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String selectedSurah = 'Fatiha';
  int selectedSurahNumber = 1;
  String selectedTranslation = 'Diyanet';
  
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSurah(1);
  }

  Future<void> _loadSurah(int surahNumber) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = ApiConfig();
      final response = await http.get(
        Uri.parse('${config.baseUrl}/quran/surah/$surahNumber'),
        headers: config.headers,
      ).timeout(config.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = (data['verses'] as List).map((v) => {
          'number': v['ayah'] ?? 0,
          'arabic': decodeHtmlEntities(v['arabic'] ?? v['text_ar'] ?? ''),
          'translation': decodeHtmlEntities(v['turkish'] ?? v['text_tr'] ?? ''),
        }).toList();

        setState(() {
          _verses = List<Map<String, dynamic>>.from(verses);
          selectedSurahNumber = surahNumber;
          selectedSurah = data['name'] ?? _getSurahName(surahNumber);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Sureler yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 72;
    
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
        children: [
          // Scrollable verses content - starts from top, scrolls under header
          _isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: headerHeight + 60),
                    child: const CircularProgressIndicator(
                      color: GlobalAppStyle.accentColor,
                    ),
                  ),
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: headerHeight + 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadSurah(selectedSurahNumber),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: headerHeight + 60,
                        bottom: 200,
                      ),
                      itemCount: _verses.length,
                      itemBuilder: (context, index) {
                        final verse = _verses[index];
                        return _buildVerseItem(verse);
                      },
                    ),
          
          // Header blur overlay (same as other pages)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 80,
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
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Header content on top
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: 40,
                child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 40,
                    height: 40,
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
                          fontSize: 20,
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
          
          // Floating selector chips with nav-bar glassmorphism
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 64,
            child: Row(
              children: [
                // Surah chip
                _buildFloatingChip(
                  '$selectedSurah $selectedSurahNumber',
                  onTap: () => _showSurahSelector(),
                ),
                const SizedBox(width: 8),
                // Translation chip
                _buildFloatingChip(
                  selectedTranslation,
                  onTap: () => _showTranslationSelector(),
                ),
              ],
            ),
          ),
          
          // Bottom navigation controls - floating glassmorphism buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous surah button
                  _buildNavButton(
                    Icons.chevron_left,
                    onTap: selectedSurahNumber > 1
                        ? () => _loadSurah(selectedSurahNumber - 1)
                        : null,
                  ),
                  
                  // Play/Audio button
                  _buildNavButton(
                    Icons.play_arrow,
                    isCenter: true,
                    onTap: () {
                      // TODO: Audio playback
                    },
                  ),
                  
                  // Next surah button
                  _buildNavButton(
                    Icons.chevron_right,
                    onTap: selectedSurahNumber < 114
                        ? () => _loadSurah(selectedSurahNumber + 1)
                        : null,
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

  Widget _buildFloatingChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.3, 1.0],
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
                  (verse['arabic'] ?? '').toString(),
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
              (verse['translation'] ?? '').toString(),
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
    final size = isCenter ? 56.0 : 48.0;
    final iconSize = isCenter ? 28.0 : 22.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.9),
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSurahSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.05),
                ],
              ),
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
                      final isSelected = selectedSurahNumber == index + 1;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? GlobalAppStyle.accentColor.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            border: isSelected
                                ? Border.all(
                                    color: GlobalAppStyle.accentColor,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isSelected
                                    ? GlobalAppStyle.accentColor
                                    : Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          _getSurahName(index + 1),
                          style: TextStyle(
                            color: isSelected
                                ? GlobalAppStyle.accentColor
                                : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: GlobalAppStyle.accentColor,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _loadSurah(index + 1);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
      'Enbiya', 'Hac', 'Mü\'minun', 'Nur', 'Furkan',
      'Şuara', 'Neml', 'Kasas', 'Ankebut', 'Rum',
      'Lokman', 'Secde', 'Ahzab', 'Sebe', 'Fatır',
      'Yasin', 'Saffat', 'Sad', 'Zümer', 'Mü\'min',
      'Fussilet', 'Şura', 'Zuhruf', 'Duhan', 'Casiye',
      'Ahkaf', 'Muhammed', 'Fetih', 'Hucurat', 'Kaf',
      'Zariyat', 'Tur', 'Necm', 'Kamer', 'Rahman',
      'Vakıa', 'Hadid', 'Mücadele', 'Haşr', 'Mümtehine',
      'Saf', 'Cum\'a', 'Münafikun', 'Teğabün', 'Talak',
      'Tahrim', 'Mülk', 'Kalem', 'Hakka', 'Mearic',
      'Nuh', 'Cin', 'Müzzemmil', 'Müddessir', 'Kıyamet',
      'İnsan', 'Mürselat', 'Nebe', 'Naziat', 'Abese',
      'Tekvir', 'İnfitar', 'Mutaffifin', 'İnşikak', 'Büruc',
      'Tarık', 'A\'la', 'Ğaşiye', 'Fecr', 'Beled',
      'Şems', 'Leyl', 'Duha', 'İnşirah', 'Tin',
      'Alak', 'Kadr', 'Beyyine', 'Zilzal', 'Adiyat',
      'Karia', 'Tekasür', 'Asr', 'Hümeze', 'Fil',
      'Kureyş', 'Maun', 'Kevser', 'Kafirun', 'Nasr',
      'Tebbet', 'İhlas', 'Felak', 'Nas',
    ];
    if (number <= surahNames.length) {
      return surahNames[number - 1];
    }
    return 'Sure $number';
  }
}

