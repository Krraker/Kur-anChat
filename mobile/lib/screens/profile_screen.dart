import 'dart:ui';
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;
  
  // Sample user data - would come from backend/state
  final Map<String, dynamic> _userData = {
    'name': 'Kullanıcı',
    'level': 7,
    'xp': 2450,
    'xpToNextLevel': 3000,
    'totalVerses': 156,
    'totalSurahs': 12,
    'streak': 14,
    'rank': 'Mümin',
    'achievements': 8,
    'completedJuz': 3,
  };

  // Quran progress data
  final List<Map<String, dynamic>> _surahProgress = [
    {'name': 'Fatiha', 'verses': 7, 'read': 7, 'completed': true},
    {'name': 'Bakara', 'verses': 286, 'read': 156, 'completed': false},
    {'name': 'Al-i İmran', 'verses': 200, 'read': 45, 'completed': false},
    {'name': 'Nisa', 'verses': 176, 'read': 0, 'completed': false},
    {'name': 'Maide', 'verses': 120, 'read': 0, 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
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
                
                // Stats Grid (Fallout-inspired)
                _buildStatsGrid(),
                
                const SizedBox(height: 24),
                
                // Quran Progress Section
                _buildQuranProgressSection(),
                
                const SizedBox(height: 24),
                
                // Achievements Preview
                _buildAchievementsSection(),
              ],
            ),
          ),
          
          // Top gradient overlay with blur and edge line
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).padding.top,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
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
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Row(
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
              
              // Settings button
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white.withOpacity(0.7),
                ),
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
      {'icon': Icons.local_fire_department, 'value': '${_userData['streak']}', 'label': 'Gün Serisi', 'color': Colors.orange},
      {'icon': Icons.menu_book, 'value': '${_userData['totalVerses']}', 'label': 'Okunan Ayet', 'color': GlobalAppStyle.accentColor},
      {'icon': Icons.auto_stories, 'value': '${_userData['totalSurahs']}', 'label': 'Sure', 'color': Colors.blue},
      {'icon': Icons.emoji_events, 'value': '${_userData['achievements']}', 'label': 'Başarı', 'color': Colors.amber},
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
                  stat['icon'] as IconData,
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

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
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
              child: Column(
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
              child: Icon(
                isCompleted ? Icons.check : Icons.menu_book_outlined,
                size: 16,
                color: isCompleted 
                    ? GlobalAppStyle.accentColor
                    : Colors.white.withOpacity(0.6),
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
        
        // Achievements horizontal scroll with images
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
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
    );
  }

  Widget _buildAchievementCard(String imagePath, String name, bool unlocked, String description) {
    return GestureDetector(
      onTap: () {
        // Show achievement details
        _showAchievementDetails(imagePath, name, unlocked, description);
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: unlocked ? [
            BoxShadow(
              color: Colors.amber.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Achievement card image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColorFiltered(
                colorFilter: unlocked 
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Locked overlay
            if (!unlocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white54,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Border decoration
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked 
                        ? Colors.amber.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: unlocked ? 1.5 : 0.5,
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withOpacity(0.7),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Achievement image
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: unlocked ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ColorFiltered(
                        colorFilter: unlocked 
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                        child: Image.asset(
                          imagePath,
                          width: 180,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Achievement name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? Colors.amber.shade300 : Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: unlocked 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: unlocked 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          unlocked ? Icons.check_circle : Icons.lock_outline,
                          size: 18,
                          color: unlocked ? Colors.green : Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          unlocked ? 'Kazanıldı!' : 'Kilitli',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: unlocked ? Colors.green : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Close button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Kapat',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
