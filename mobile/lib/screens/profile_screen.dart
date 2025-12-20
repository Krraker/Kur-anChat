import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';
import '../services/subscription_service.dart';
import '../services/reading_progress_service.dart';
import 'paywall/pro_paywall_screen.dart';
import 'debug/revenuecat_debug_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;
  
  // Reading progress service
  final ReadingProgressService _progressService = ReadingProgressService();
  bool _isProgressLoaded = false;
  
  // User data - some static, some dynamic from reading progress
  Map<String, dynamic> _userData = {
    'name': 'Kullanıcı',
    'level': 7,
    'xp': 2450,
    'xpToNextLevel': 3000,
    'totalVerses': 0,
    'totalSurahs': 0,
    'streak': 14,
    'rank': 'Mümin',
    'achievements': 8,
    'completedJuz': 0,
  };

  // Quran progress data - dynamically loaded from ReadingProgressService
  List<Map<String, dynamic>> _surahProgress = [];

  // Surah names for display
  static const List<String> _surahNames = [
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

  @override
  void initState() {
    super.initState();
    _initReadingProgress();
    _progressAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimController,
      curve: Curves.easeOutCubic,
    );
    _progressAnimController.forward();
  }

  /// Initialize reading progress from the service
  Future<void> _initReadingProgress() async {
    await _progressService.init();
    _loadProgressData();
  }

  /// Load and calculate progress data from the service
  void _loadProgressData() {
    // Build surah progress list - show first 10 surahs with any progress, plus next 5 unread
    final List<Map<String, dynamic>> progressList = [];
    int totalVersesRead = 0;
    int completedSurahCount = 0;
    
    // First, add all surahs that have progress
    for (int i = 1; i <= 114; i++) {
      final versesRead = _progressService.getVersesReadCount(i);
      final totalVerses = _progressService.getTotalVerses(i);
      final isCompleted = _progressService.isSurahCompleted(i);
      
      totalVersesRead += versesRead;
      if (isCompleted) completedSurahCount++;
      
      if (versesRead > 0 || progressList.length < 5) {
        progressList.add({
          'number': i,
          'name': i <= _surahNames.length ? _surahNames[i - 1] : 'Sure $i',
          'verses': totalVerses,
          'read': versesRead,
          'completed': isCompleted,
        });
      }
      
      // Limit to 10 surahs max for display
      if (progressList.length >= 10) break;
    }
    
    // If we have less than 5 surahs, add more unread ones
    if (progressList.length < 5) {
      for (int i = 1; i <= 114; i++) {
        final alreadyAdded = progressList.any((s) => s['number'] == i);
        if (!alreadyAdded) {
          progressList.add({
            'number': i,
            'name': i <= _surahNames.length ? _surahNames[i - 1] : 'Sure $i',
            'verses': _progressService.getTotalVerses(i),
            'read': 0,
            'completed': false,
          });
          if (progressList.length >= 5) break;
        }
      }
    }
    
    // Sort by surah number
    progressList.sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    
    // Calculate completed juz (approximate: 6236 verses / 30 juz ≈ 208 verses per juz)
    final completedJuz = (totalVersesRead / 208).floor().clamp(0, 30);
    
    setState(() {
      _surahProgress = progressList;
      _userData = {
        ..._userData,
        'totalVerses': totalVersesRead,
        'totalSurahs': completedSurahCount,
        'completedJuz': completedJuz,
      };
      _isProgressLoaded = true;
    });
  }

  @override
  void dispose() {
    _progressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16, 
              MediaQuery.of(context).padding.top + 16, 
              16, 
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and level
                _buildProfileHeader(),
                
                const SizedBox(height: 24),
                
                // XP Progress Bar
                _buildXPBar(),
                
                const SizedBox(height: 24),
                
                // Achievements Preview
                _buildAchievementsSection(),
                
                const SizedBox(height: 24),
                
                // Quran Progress Section
                _buildQuranProgressSection(),
                
                const SizedBox(height: 24),
                
                // Stats Grid (Fallout-inspired)
                _buildStatsGrid(),
              ],
            ),
          ),
          
          // Top status bar - Glassmorphism effect
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: MediaQuery.of(context).padding.top,
                  decoration: BoxDecoration(
                    // Glassmorphism gradient
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.12),
                        Colors.white.withOpacity(0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    // Bottom edge highlight
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Glassmorphism gradient - lighter at top, darker at bottom
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.05),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            // Top highlight edge for glass effect
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            // Subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              // Inner glow effect
              BoxShadow(
                color: GlobalAppStyle.accentColor.withOpacity(0.05),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top shine highlight for glass effect
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              // Main content row
              Row(
                children: [
                  // Avatar with level badge
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              GlobalAppStyle.accentColor.withOpacity(0.3),
                              GlobalAppStyle.accentColor.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: GlobalAppStyle.accentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _userData['name'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Level badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GlobalAppStyle.accentColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: GlobalAppStyle.accentColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'LV.${_userData['level']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Name and rank
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech,
                                size: 14,
                                color: Colors.amber.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _userData['rank'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings button with menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    color: const Color(0xFF1A1A1A),
                    onSelected: (value) {
                      switch (value) {
                        case 'upgrade':
                          showProPaywall(context);
                          break;
                        case 'debug':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RevenueCatDebugScreen(),
                            ),
                          );
                          break;
                        case 'manage':
                          SubscriptionService().presentCustomerCenter();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'upgrade',
                        child: Row(
                          children: [
                            Icon(Icons.workspace_premium, 
                                 color: GlobalAppStyle.accentColor, size: 20),
                            const SizedBox(width: 12),
                            const Text('Pro\'ya Yükselt', 
                                       style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'manage',
                        child: Row(
                          children: [
                            Icon(Icons.credit_card, 
                                 color: Colors.white.withOpacity(0.7), size: 20),
                            const SizedBox(width: 12),
                            const Text('Abonelik Yönet', 
                                       style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'debug',
                        child: Row(
                          children: [
                            Icon(Icons.bug_report, 
                                 color: Colors.orange.withOpacity(0.7), size: 20),
                            const SizedBox(width: 12),
                            const Text('RevenueCat Debug', 
                                       style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXPBar() {
    final xpProgress = _userData['xp'] / _userData['xpToNextLevel'];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: GlobalAppStyle.accentColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'TECRÜBE PUANI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_userData['xp']} / ${_userData['xpToNextLevel']} XP',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GlobalAppStyle.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // XP Progress bar with animation
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Background track
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      // Progress fill
                      FractionallySizedBox(
                        widthFactor: xpProgress * _progressAnimation.value,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              colors: [
                                GlobalAppStyle.accentColor,
                                GlobalAppStyle.accentColor.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GlobalAppStyle.accentColor.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Glow effect at the end
                      if (_progressAnimation.value > 0.5)
                        Positioned(
                          left: (MediaQuery.of(context).size.width - 64) * xpProgress * _progressAnimation.value - 8,
                          child: Container(
                            width: 16,
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Sonraki seviye: ${_userData['xpToNextLevel'] - _userData['xp']} XP kaldı',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'icon': null, 'svgPath': 'assets/UI/ICONS/fireicon.svg', 'value': '${_userData['streak']}', 'label': 'Gün Serisi', 'color': Colors.orange},
      {'icon': null, 'svgPath': 'assets/icons/quran_icon.svg', 'value': '${_userData['totalVerses']}', 'label': 'Okunan Ayet', 'color': GlobalAppStyle.accentColor},
      {'icon': Icons.auto_stories, 'svgPath': null, 'value': '${_userData['totalSurahs']}', 'label': 'Sure', 'color': Colors.blue},
      {'icon': Icons.emoji_events, 'svgPath': null, 'value': '${_userData['achievements']}', 'label': 'Başarı', 'color': Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: GlobalAppStyle.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'İSTATİSTİKLER',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: stats.map((stat) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildStatCard(
                  stat['icon'] as IconData?,
                  stat['svgPath'] as String?,
                  stat['value'] as String,
                  stat['label'] as String,
                  stat['color'] as Color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData? icon, String? svgPath, String value, String label, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              if (svgPath != null)
                SvgPicture.asset(
                  svgPath,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                )
              else
                Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuranProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: GlobalAppStyle.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'KUR\'AN İLERLEMESİ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GlobalAppStyle.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_userData['completedJuz']}/30 Cüz',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GlobalAppStyle.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Surah progress list
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: !_isProgressLoaded
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GlobalAppStyle.accentColor,
                          ),
                        ),
                      ),
                    )
                  : _surahProgress.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Henüz okuma yok.\nKur\'an sayfasından okumaya başlayın!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: _surahProgress.asMap().entries.map((entry) {
                            final index = entry.key;
                            final surah = entry.value;
                            final isLast = index == _surahProgress.length - 1;
                            return _buildSurahProgressItem(surah, isLast);
                          }).toList(),
                        ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // View all button
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tüm Sureleri Gör',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GlobalAppStyle.accentColor,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: GlobalAppStyle.accentColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahProgressItem(Map<String, dynamic> surah, bool isLast) {
    final progress = surah['read'] / surah['verses'];
    final isCompleted = surah['completed'] as bool;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? GlobalAppStyle.accentColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: isCompleted 
                    ? GlobalAppStyle.accentColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Center(
              child: isCompleted 
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: GlobalAppStyle.accentColor,
                    )
                  : SvgPicture.asset(
                      'assets/icons/quran_icon.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.6),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Surah name and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted 
                        ? GlobalAppStyle.accentColor
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress bar
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: progress * _progressAnimation.value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: isCompleted 
                                  ? GlobalAppStyle.accentColor
                                  : GlobalAppStyle.accentColor.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Verse count
          Text(
            '${surah['read']}/${surah['verses']}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    // Achievement cards with image assets
    final achievements = [
      {'image': 'assets/achievements/day_1.png', 'name': 'İlk Gün', 'unlocked': true, 'description': 'İlk günü tamamla'},
      {'image': 'assets/achievements/day_7.png', 'name': '7. Gün', 'unlocked': true, 'description': '7 gün üst üste giriş yap'},
      {'image': 'assets/achievements/day_30.png', 'name': '30. Gün', 'unlocked': false, 'description': '30 gün üst üste giriş yap'},
      {'image': 'assets/achievements/verse_100.png', 'name': '100 Ayet', 'unlocked': true, 'description': '100 ayet oku'},
      {'image': 'assets/achievements/verse_1000.png', 'name': '1000 Ayet', 'unlocked': false, 'description': '1000 ayet oku'},
    ];

    final unlockedCount = achievements.where((a) => a['unlocked'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BAŞARILAR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                '$unlockedCount / ${achievements.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade400,
                ),
              ),
            ],
          ),
        ),
        
        // Achievements horizontal scroll - extends to screen edges for proper clipping
        SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -20, // Extend to left screen edge
                    right: -20, // Extend to right screen edge
                    top: 0,
                    bottom: 0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: achievements.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return _buildAchievementCard(
                          achievement['image'] as String,
                          achievement['name'] as String,
                          achievement['unlocked'] as bool,
                          achievement['description'] as String,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _buildAchievementCard(String imagePath, String name, bool unlocked, String description) {
    return GestureDetector(
      onTap: () {
        // Show achievement details
        _showAchievementDetails(imagePath, name, unlocked, description);
      },
      child: SizedBox(
        width: 130,
        height: 180,
        child: Stack(
          children: [
            // Card image
            ColorFiltered(
              colorFilter: unlocked 
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.5, 0,
                    ]),
              child: Image.asset(
                imagePath,
                width: 130,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            // Lock icon for locked cards - bottom center
            if (!unlocked)
              Positioned(
                bottom: 25,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(String imagePath, String name, bool unlocked, String description) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Big achievement card image - larger and closer to edges
                        ColorFiltered(
                          colorFilter: unlocked 
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0, 0, 0, 0.5, 0,
                                ]),
                          child: Image.asset(
                            imagePath,
                            width: 360,
                            height: 500,
                            fit: BoxFit.contain,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Status at bottom
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              unlocked ? Icons.check_circle : Icons.lock_outline,
                              size: 18,
                              color: unlocked ? Colors.green.shade400 : Colors.white38,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              unlocked ? 'Kazanıldı' : 'Kilitli',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: unlocked ? Colors.green.shade400 : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Glass-like reveal with eased opacity - same as calendar
        final opacityAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        );
        final scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
        );
        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(scaleAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
