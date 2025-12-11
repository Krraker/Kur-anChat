import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentLivePrayerSeconds = 15;
  Timer? _timer;
  
  // Online users animation
  int _onlineUsers = 2495095;
  Timer? _onlineUsersTimer;
  final Random _random = Random();

  // Sample data - would come from backend
  final List<Map<String, dynamic>> _waitingPrayers = [
    {
      'name': 'Ahmet Yılmaz',
      'prayer': 'Ailem için sağlık ve huzur diliyorum. Allah\'ım bize sabır ve şükür ver.',
      'status': 'next',
    },
    {
      'name': 'Fatma Kaya',
      'prayer': 'İş hayatımda başarı ve bereket için dua ediyorum. Rızkımı genişlet Ya Rabbi.',
      'status': '1',
    },
    {
      'name': 'Mehmet Demir',
      'prayer': 'Sınavlarımda başarılı olmam için dua istiyorum. Allah\'ım yardımcım ol.',
      'status': '3',
    },
    {
      'name': 'Ayşe Öztürk', 
      'prayer': 'Hastanedeki anneannem için şifa diliyorum. Şafi olan sensin Ya Rabbi.',
      'status': '5',
    },
  ];

  final Map<String, dynamic> _currentLivePrayer = {
    'name': 'Zeynep Arslan',
    'prayer': 'Hayatımda doğru kararlar vermem ve doğru zamanlama için dua ediyorum. Allah\'ım bana yol göster, kalbimi nurlandır ve beni doğru yola ilet.',
    'timeLeft': 15,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startTimer();
    _startOnlineUsersAnimation();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentLivePrayerSeconds > 0) {
        setState(() {
          _currentLivePrayerSeconds--;
        });
      } else {
        // Reset for demo
        setState(() {
          _currentLivePrayerSeconds = 30;
        });
      }
    });
  }

  void _startOnlineUsersAnimation() {
    // Variable interval for more natural feeling
    void scheduleNextUpdate() {
      // Random interval between 800ms and 3000ms
      final interval = 800 + _random.nextInt(2200);
      _onlineUsersTimer = Timer(Duration(milliseconds: interval), () {
        if (!mounted) return;
        
        // Different patterns: sometimes big changes, sometimes small
        final pattern = _random.nextInt(100);
        int change;
        
        if (pattern < 60) {
          // 60% - Small fluctuation (1-50)
          change = 1 + _random.nextInt(50);
        } else if (pattern < 85) {
          // 25% - Medium fluctuation (50-200)
          change = 50 + _random.nextInt(150);
        } else {
          // 15% - Larger fluctuation (200-800)
          change = 200 + _random.nextInt(600);
        }
        
        // 45% chance to lose users, 55% to gain (slight upward trend)
        final isGain = _random.nextDouble() > 0.45;
        
        setState(() {
          if (isGain) {
            _onlineUsers += change;
          } else {
            _onlineUsers -= change;
            // Keep minimum reasonable
            if (_onlineUsers < 2400000) _onlineUsers = 2400000 + _random.nextInt(50000);
          }
        });
        
        scheduleNextUpdate();
      });
    }
    
    scheduleNextUpdate();
  }
  
  String _formatOnlineUsers(int count) {
    // Format as X.XXX.XXX
    final str = count.toString();
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      counter++;
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    _onlineUsersTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Header
              _buildHeader(),
              
              // Tab bar
              _buildTabBar(),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLivePrayersTab(),
                    _buildWorldEventsTab(),
                  ],
                ),
              ),
            ],
          ),
          
          // Floating Request Prayer button
          Positioned(
            bottom: 140,
            right: 16,
            child: _buildRequestPrayerButton(),
          ),
          
          // Top gradient overlay with edge line
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
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
          
          const SizedBox(width: 12),
          
          // Title
          const Expanded(
            child: Text(
              'Topluluk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // My Prayers button
          GestureDetector(
            onTap: () {
              // Navigate to my prayers
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dualarım',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_border, size: 18),
                const SizedBox(width: 6),
                const Text('Canlı Dualar'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 18),
                const SizedBox(width: 6),
                const Text('Dünya Olayları'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePrayersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right Now section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Şu Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '1.234 kişi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Current live prayer card
          _buildCurrentLivePrayerCard(),
          
          const SizedBox(height: 28),
          
          // Waiting section
          Text(
            'BEKLEMEDE • ${_waitingPrayers.length} DUA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Waiting prayers list
          ...List.generate(_waitingPrayers.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildWaitingPrayerCard(_waitingPrayers[index]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentLivePrayerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8B5A2B).withOpacity(0.6),
                  const Color(0xFFD4A574).withOpacity(0.4),
                  const Color(0xFFE8C4A0).withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentLivePrayer['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '$_currentLivePrayerSeconds sn kaldı',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Prayer text
                Text(
                  _currentLivePrayer['prayer'],
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Join button and online users
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Join button
                    GestureDetector(
                      onTap: () {
                        _showLivePrayerRoom();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        child: const Text(
                          'Canlı Duaya Katıl',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Online users indicator - aligned right
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: GlobalAppStyle.accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: GlobalAppStyle.accentColor.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatOnlineUsers(_onlineUsers)} çevrimiçi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingPrayerCard(Map<String, dynamic> prayer) {
    final isNext = prayer['status'] == 'next';
    final statusText = isNext ? 'SIRADA' : '${prayer['status']} DK\'DA';
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prayer['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isNext 
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(isNext ? 0.3 : 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white.withOpacity(isNext ? 1.0 : 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Prayer text
              Text(
                prayer['prayer'],
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldEventsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Dünya Olayları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dünya genelinde önemli olaylar ve\ntopluluk duaları için bizi takip edin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestPrayerButton() {
    return GestureDetector(
      onTap: () {
        _showRequestPrayerModal();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dua Talep Et',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLivePrayerRoom() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Live Prayer Room',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LivePrayerRoomDialog(
          prayer: _currentLivePrayer,
          onlineCount: _onlineUsers,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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

  void _showRequestPrayerModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Prayer Request',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
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
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              const Text(
                                'Dua Talep Et',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duanızı yazın',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 150,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 0.5,
                                  ),
                                ),
                                child: TextField(
                                  maxLines: null,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Dua talebinizi buraya yazın...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Submit button - glassmorphism style
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Dua talebiniz gönderildi'),
                                      backgroundColor: GlobalAppStyle.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Dua Talep Et',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
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
        // Glass-like reveal with eased opacity
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

/// Live Prayer Room Dialog - Monochrome with Sacred Geometry Layout
class _LivePrayerRoomDialog extends StatefulWidget {
  final Map<String, dynamic> prayer;
  final int onlineCount;

  const _LivePrayerRoomDialog({
    required this.prayer,
    required this.onlineCount,
  });

  @override
  State<_LivePrayerRoomDialog> createState() => _LivePrayerRoomDialogState();
}

class _LivePrayerRoomDialogState extends State<_LivePrayerRoomDialog> with TickerProviderStateMixin {
  // Dynamic participant list - can grow with more rings
  List<_Participant?> _spiralParticipants = [];
  int _currentRingCount = 2; // Start with 2 rings (inner + outer)
  Timer? _participantTimer;
  final Random _random = Random();
  int _aminCount = 1247;
  bool _hasCompletedFirstAmin = false;
  bool _isHoldingAmin = false;
  int _currentLine = 0; // Current line being highlighted
  double _lineProgress = 0.0; // Progress within current line
  Timer? _karaokeTimer;
  List<String> _prayerLines = [];
  
  // Floating emoji animations (Instagram-style)
  final List<_FloatingEmoji> _floatingEmojis = [];
  Timer? _randomEmojiTimer;
  
  // Active connections between online participants (animated glowing lines)
  final List<_ParticipantConnection> _activeConnections = [];
  
  // Monochrome color
  static const Color _monoColor = Colors.white;
  static const Color _connectionGlowColor = Color(0xFFFFD700); // Golden yellow
  
  // Sample names
  static const List<String> _sampleNames = [
    'Ahmet', 'Fatma', 'Mehmet', 'Ayşe', 'Mustafa', 'Zeynep', 'Ali', 'Elif',
    'Hasan', 'Hatice', 'İbrahim', 'Merve', 'Yusuf', 'Esra', 'Ömer', 'Büşra',
    'Emre', 'Selin', 'Burak', 'Derya', 'Kemal', 'Gizem', 'Serkan', 'Aslı',
  ];

  // Calculate total positions based on ring count
  int get _totalPositions => 1 + (_currentRingCount * 6);
  
  // Scale factor based on ring count (zoom out as more people join)
  double get _scaleFactor {
    if (_currentRingCount <= 2) return 1.0;
    if (_currentRingCount == 3) return 0.75;
    if (_currentRingCount == 4) return 0.6;
    return 0.5;
  }

  // Spiral positions: center + multiple hexagonal rings
  List<Offset> _getSpiralPositions(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.18 * _scaleFactor;
    
    final positions = <Offset>[
      center, // Center position (index 0) - Zeynep
    ];
    
    // Generate rings
    for (int ring = 1; ring <= _currentRingCount; ring++) {
      final radius = baseRadius * ring * 1.1;
      final offsetAngle = ring.isOdd ? -90 : -60; // Alternate offset
      
      for (int i = 0; i < 6; i++) {
        final angle = (i * 60 + offsetAngle) * (3.14159 / 180);
        positions.add(Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ));
      }
    }
    
    return positions;
  }


  @override
  void initState() {
    super.initState();
    
    // Split prayer into lines
    final prayerText = widget.prayer['prayer'] as String;
    _prayerLines = _splitIntoLines(prayerText);
    
    // Initialize participants list
    _spiralParticipants = List.filled(_totalPositions, null);
    
    // Position 0 is always Zeynep (prayer host)
    _spiralParticipants[0] = _Participant(
      name: widget.prayer['name'],
      animationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      )..forward(),
    );
    
    // Fill other positions randomly
    for (int i = 1; i < _totalPositions; i++) {
      if (_random.nextDouble() > 0.25) {
        _fillPosition(i);
      }
    }
    _startParticipantAnimation();
    _startAminAnimation();
    _startRandomEmojiSpawns();
  }
  
  void _startRandomEmojiSpawns() {
    // Spawn random emojis from "other users" hitting amin
    _randomEmojiTimer = Timer.periodic(Duration(milliseconds: 800 + _random.nextInt(1500)), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Random chance to spawn emoji (simulating other users)
      if (_random.nextDouble() < 0.6) {
        _spawnFloatingEmoji();
      }
    });
  }
  
  void _spawnFloatingEmoji() {
    if (!mounted) return;
    
    final controller = AnimationController(
      duration: Duration(milliseconds: 1500 + _random.nextInt(800)),
      vsync: this,
    );
    
    // Random horizontal position (left side bias for variety)
    final startX = 20.0 + _random.nextDouble() * 80; // 20-100 from left
    final emoji = _FloatingEmoji(
      id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
      startX: startX,
      animationController: controller,
    );
    
    setState(() {
      _floatingEmojis.add(emoji);
    });
    
    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere((e) => e.id == emoji.id);
        });
        controller.dispose();
      }
    });
  }
  
  List<String> _splitIntoLines(String text) {
    // Split by punctuation or roughly every 40 chars
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';
    
    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if (currentLine.length + word.length + 1 > 35) {
        lines.add(currentLine);
        currentLine = word;
      } else {
        currentLine += ' $word';
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    
    return lines.isEmpty ? [text] : lines;
  }

  void _startAminAnimation() {
    Timer.periodic(Duration(milliseconds: 2000 + _random.nextInt(4000)), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _aminCount += 1 + _random.nextInt(8);
      });
    });
  }

  void _startParticipantAnimation() {
    _participantTimer = Timer.periodic(Duration(milliseconds: 1800 + _random.nextInt(2500)), (timer) {
      if (!mounted) return;
      
      // Find empty and filled positions (skip center - index 0)
      final emptyPositions = <int>[];
      final filledPositions = <int>[];
      
      for (int i = 1; i < _spiralParticipants.length; i++) {
        if (_spiralParticipants[i] == null) {
          emptyPositions.add(i);
        } else {
          filledPositions.add(i);
        }
      }
      
      final action = _random.nextInt(100);
      
      // Check if we should expand to a new ring
      if (action < 10 && _currentRingCount < 4 && filledPositions.length > _totalPositions * 0.8) {
        setState(() {
          _currentRingCount++;
          final newTotal = _totalPositions;
          while (_spiralParticipants.length < newTotal) {
            _spiralParticipants.add(null);
          }
        });
        return;
      }
      
      if (action < 35 && emptyPositions.isNotEmpty) {
        final pos = emptyPositions[_random.nextInt(emptyPositions.length)];
        setState(() => _fillPosition(pos));
      } else if (action < 65 && filledPositions.length > 5) {
        final pos = filledPositions[_random.nextInt(filledPositions.length)];
        // Remove connections when participant goes offline
        _removeConnectionsForParticipant(pos);
        _spiralParticipants[pos]?.animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _spiralParticipants[pos]?.animationController.dispose();
              _spiralParticipants[pos] = null;
            });
          }
        });
      } else if (filledPositions.isNotEmpty && emptyPositions.isNotEmpty) {
        final removePos = filledPositions[_random.nextInt(filledPositions.length)];
        final addPos = emptyPositions[_random.nextInt(emptyPositions.length)];
        
        // Remove connections when participant goes offline
        _removeConnectionsForParticipant(removePos);
        _spiralParticipants[removePos]?.animationController.reverse();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _spiralParticipants[removePos]?.animationController.dispose();
              _spiralParticipants[removePos] = null;
              _fillPosition(addPos);
            });
          }
        });
      }
    });
  }

  void _fillPosition(int index) {
    if (index == 0) return; // Never replace center
    final name = _sampleNames[_random.nextInt(_sampleNames.length)];
    
    _spiralParticipants[index] = _Participant(
      name: name,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      )..forward(),
    );
    
    // Create connections to all nearby online participants
    _createConnectionsToNearby(index);
  }
  
  void _createConnectionsToNearby(int newIndex) {
    // Find all online participants (excluding the new one)
    final onlineIndices = <int>[];
    for (int i = 0; i < _spiralParticipants.length; i++) {
      if (i != newIndex && _spiralParticipants[i] != null) {
        onlineIndices.add(i);
      }
    }
    
    if (onlineIndices.isEmpty) return;
    
    // Only connect to immediately adjacent neighbors (one step away)
    final adjacentIndices = _getAdjacentPositions(newIndex);
    final nearbyOnline = adjacentIndices.where((idx) => 
      idx < _spiralParticipants.length && _spiralParticipants[idx] != null
    ).toList();
    
    // If no adjacent online, connect to the single closest one
    if (nearbyOnline.isEmpty) {
      int nearestIndex = onlineIndices.first;
      int minDistance = _getPositionDistance(newIndex, nearestIndex);
      for (final idx in onlineIndices) {
        final dist = _getPositionDistance(newIndex, idx);
        if (dist < minDistance) {
          minDistance = dist;
          nearestIndex = idx;
        }
      }
      nearbyOnline.add(nearestIndex);
    }
    
    // Create connections to adjacent online participants only
    for (int i = 0; i < nearbyOnline.length; i++) {
      final targetIndex = nearbyOnline[i];
      
      // Check if connection already exists
      final exists = _activeConnections.any((c) => 
        (c.fromIndex == newIndex && c.toIndex == targetIndex) ||
        (c.fromIndex == targetIndex && c.toIndex == newIndex)
      );
      
      if (exists) continue;
      
      // Stagger the animations slightly for visual effect
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!mounted) return;
        
        final connectionController = AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        );
        
        final connection = _ParticipantConnection(
          fromIndex: newIndex,
          toIndex: targetIndex,
          animationController: connectionController,
        );
        
        setState(() {
          _activeConnections.add(connection);
        });
        connectionController.forward();
      });
    }
  }
  
  // Get positions that are exactly one step adjacent in the sacred geometry
  List<int> _getAdjacentPositions(int index) {
    if (index == 0) {
      // Center connects to all inner ring (1-6)
      return [1, 2, 3, 4, 5, 6];
    }
    
    final ring = ((index - 1) ~/ 6) + 1;
    final posInRing = (index - 1) % 6;
    final ringStart = 1 + (ring - 1) * 6;
    
    final adjacent = <int>[];
    
    // Neighbors in same ring (left and right)
    final leftInRing = ringStart + ((posInRing - 1 + 6) % 6);
    final rightInRing = ringStart + ((posInRing + 1) % 6);
    adjacent.add(leftInRing);
    adjacent.add(rightInRing);
    
    // Connect to inner ring or center
    if (ring == 1) {
      // Inner ring connects to center
      adjacent.add(0);
    } else {
      // Connect to corresponding position in inner ring
      final innerRingStart = 1 + (ring - 2) * 6;
      adjacent.add(innerRingStart + posInRing);
      // Also connect to adjacent position in inner ring
      adjacent.add(innerRingStart + ((posInRing + 1) % 6));
    }
    
    // Connect to outer ring if exists
    final outerRingStart = 1 + ring * 6;
    if (outerRingStart < _totalPositions) {
      adjacent.add(outerRingStart + posInRing);
      adjacent.add(outerRingStart + ((posInRing - 1 + 6) % 6));
    }
    
    return adjacent;
  }
  
  void _removeConnectionsForParticipant(int index) {
    // Remove all connections involving this participant
    final toRemove = _activeConnections.where(
      (c) => c.fromIndex == index || c.toIndex == index
    ).toList();
    
    for (final connection in toRemove) {
      connection.animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _activeConnections.remove(connection);
          });
          connection.animationController.dispose();
        }
      });
    }
  }
  
  int _getPositionDistance(int a, int b) {
    // Simple distance calculation based on ring and position
    final ringA = a == 0 ? 0 : ((a - 1) ~/ 6) + 1;
    final ringB = b == 0 ? 0 : ((b - 1) ~/ 6) + 1;
    final posInRingA = a == 0 ? 0 : (a - 1) % 6;
    final posInRingB = b == 0 ? 0 : (b - 1) % 6;
    
    // Ring difference + position difference (wrapping around 6)
    final ringDiff = (ringA - ringB).abs();
    final posDiff = ((posInRingA - posInRingB).abs()).clamp(0, 3);
    
    return ringDiff * 2 + posDiff;
  }

  void _startKaraoke() {
    _isHoldingAmin = true;
    _currentLine = 0;
    _lineProgress = 0.0;
    _karaokeTimer?.cancel();
    
    _karaokeTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted || !_isHoldingAmin) {
        timer.cancel();
        return;
      }
      setState(() {
        _lineProgress += 0.04; // Progress within current line
        
        if (_lineProgress >= 1.0) {
          _lineProgress = 0.0;
          _currentLine++;
          
          if (_currentLine >= _prayerLines.length) {
            // Completed all lines
            _completeAmin();
            timer.cancel();
          }
        }
      });
    });
  }

  void _stopKaraoke() {
    _isHoldingAmin = false;
    _karaokeTimer?.cancel();
    if (_currentLine < _prayerLines.length) {
      setState(() {
        _currentLine = 0;
        _lineProgress = 0.0;
      });
    }
  }

  void _completeAmin() {
    setState(() {
      _aminCount++;
      _hasCompletedFirstAmin = true;
      _currentLine = _prayerLines.length; // Keep all lines highlighted
      _lineProgress = 1.0;
    });
    // Spawn burst of emojis on complete
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _spawnFloatingEmoji();
      });
    }
  }

  void _quickAmin() {
    if (_hasCompletedFirstAmin) {
      setState(() {
        _aminCount++;
      });
      // Spawn emoji on quick amin
      _spawnFloatingEmoji();
    }
  }

  @override
  void dispose() {
    _participantTimer?.cancel();
    _karaokeTimer?.cancel();
    _randomEmojiTimer?.cancel();
    for (var p in _spiralParticipants) {
      p?.animationController.dispose();
    }
    for (var e in _floatingEmojis) {
      e.animationController.dispose();
    }
    for (var c in _activeConnections) {
      c.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  // Monochrome gradient
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                  border: Border.all(
                    color: _monoColor.withOpacity(0.15),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Main content
                    Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildSacredGeometryLayout()),
                        _buildAminCounter(),
                        const SizedBox(height: 8),
                        _buildPrayerSection(),
                      ],
                    ),
                    // Floating emojis overlay
                    ..._floatingEmojis.map((emoji) => _buildFloatingEmoji(emoji)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Live indicator - RED like Instagram
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'CANLI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Online users count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _monoColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _monoColor.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: GlobalAppStyle.accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: GlobalAppStyle.accentColor.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${_spiralParticipants.where((p) => p != null).length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _monoColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _monoColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: _monoColor.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAminCounter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _monoColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _monoColor.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤲', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            _formatNumber(_aminCount),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _monoColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Amin',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _monoColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }

  Widget _buildSacredGeometryLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final positions = _getSpiralPositions(size);
        final circleSize = 48.0 * _scaleFactor;
        final halfSize = circleSize / 2;
        final totalWidgetWidth = circleSize + 20; // Circle + some padding for name
        
        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sacred geometry lines (connecting circles)
              CustomPaint(
                size: size,
                painter: _SacredGeometryPainter(positions, _monoColor, _currentRingCount),
              ),
              
              // Animated glowing connection lines between online participants
              ..._activeConnections.map((connection) => 
                _buildAnimatedConnection(connection, positions),
              ),
              
              // Dark backing behind circles and names to cover the lines
              ...List.generate(_spiralParticipants.length.clamp(0, positions.length), (index) {
                if (index >= positions.length) return const SizedBox.shrink();
                final pos = positions[index];
                final participant = _spiralParticipants[index];
                if (participant == null) return const SizedBox.shrink();
                
                return Positioned(
                  left: pos.dx - halfSize - 4,
                  top: pos.dy - halfSize - 4,
                  child: Container(
                    width: circleSize + 8,
                    height: circleSize + 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(circleSize),
                    ),
                  ),
                );
              }),
              
              // Participant circles with names
              ...List.generate(_spiralParticipants.length.clamp(0, positions.length), (index) {
                if (index >= positions.length) return const SizedBox.shrink();
                final pos = positions[index];
                final participant = _spiralParticipants[index];
                
                return Positioned(
                  left: pos.dx - totalWidgetWidth / 2,
                  top: pos.dy - halfSize,
                  width: totalWidgetWidth,
                  child: _buildParticipantCircle(participant, index == 0, circleSize),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedConnection(_ParticipantConnection connection, List<Offset> positions) {
    if (connection.fromIndex >= positions.length || connection.toIndex >= positions.length) {
      return const SizedBox.shrink();
    }
    
    final fromPos = positions[connection.fromIndex];
    final toPos = positions[connection.toIndex];
    final circleRadius = (48.0 * _scaleFactor) / 2; // Half of circle size
    
    return AnimatedBuilder(
      animation: connection.animationController,
      builder: (context, child) {
        final progress = Curves.easeOut.transform(connection.animationController.value);
        
        return CustomPaint(
          size: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ),
          painter: _GlowingConnectionPainter(
            from: fromPos,
            to: toPos,
            progress: progress,
            glowColor: _connectionGlowColor,
            circleRadius: circleRadius,
          ),
        );
      },
    );
  }

  Widget _buildParticipantCircle(_Participant? participant, bool isCenter, double size) {
    final fontSize = size * 0.35;
    
    if (participant == null) {
      return Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _monoColor.withOpacity(0.03),
            border: Border.all(
              color: _monoColor.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
      );
    }
    
    return AnimatedBuilder(
      animation: participant.animationController,
      builder: (context, child) {
        final value = participant.animationController.value;
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.7 + (value * 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCenter 
                        ? _monoColor.withOpacity(0.2)
                        : _monoColor.withOpacity(0.1),
                    border: Border.all(
                      color: _monoColor.withOpacity(isCenter ? 0.6 : 0.3),
                      width: isCenter ? 2 : 1,
                    ),
                    boxShadow: isCenter ? [
                      BoxShadow(
                        color: _monoColor.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      participant.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: _monoColor.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  participant.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w500,
                    color: _monoColor.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _monoColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _monoColor.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Left aligned
        children: [
          // Line-by-line karaoke text
          ..._prayerLines.asMap().entries.map((entry) {
            final lineIndex = entry.key;
            final lineText = entry.value;
            
            // Determine line state
            final isCompleted = lineIndex < _currentLine;
            final isCurrentLine = lineIndex == _currentLine && _isHoldingAmin;
            final progress = isCurrentLine ? _lineProgress : (isCompleted ? 1.0 : 0.0);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Stack(
                children: [
                  // Base text (dim)
                  Text(
                    lineText,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: _monoColor.withOpacity(0.25),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // Highlighted text with karaoke effect
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _monoColor,
                          _monoColor,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          progress.clamp(0.0, 1.0),
                          progress.clamp(0.0, 1.0),
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      lineText,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: _monoColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 20),
          
          // Amin button with hold gesture - centered
          Center(
            child: GestureDetector(
              onTapDown: (_) {
                if (_hasCompletedFirstAmin) {
                  _quickAmin();
                } else {
                  _startKaraoke();
                }
              },
              onTapUp: (_) => _stopKaraoke(),
              onTapCancel: () => _stopKaraoke(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isHoldingAmin 
                      ? _monoColor.withOpacity(0.18)
                      : _monoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _monoColor.withOpacity(_isHoldingAmin ? 0.35 : 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🤲', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      _hasCompletedFirstAmin ? 'Amin' : 'Basılı Tut',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _monoColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_hasCompletedFirstAmin) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Duayı tamamlamak için basılı tutun',
                style: TextStyle(
                  fontSize: 11,
                  color: _monoColor.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFloatingEmoji(_FloatingEmoji emoji) {
    return AnimatedBuilder(
      animation: emoji.animationController,
      builder: (context, child) {
        final progress = emoji.animationController.value;
        
        // Easing curves for natural motion
        final yOffset = Curves.easeOut.transform(progress) * 300;
        final opacity = 1.0 - Curves.easeIn.transform(progress);
        final scale = 1.0 + (progress * 0.3); // Slight grow as it rises
        
        // Slight horizontal wobble
        final wobble = sin(progress * 6 * 3.14159) * 8;
        
        return Positioned(
          left: emoji.startX + wobble,
          bottom: 180 + yOffset, // Start above the amin button
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: const Text(
                '🤲',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingEmoji {
  final int id;
  final double startX;
  final AnimationController animationController;
  
  _FloatingEmoji({
    required this.id,
    required this.startX,
    required this.animationController,
  });
}

class _Participant {
  final String name;
  final AnimationController animationController;

  _Participant({
    required this.name,
    required this.animationController,
  });
}

class _ParticipantConnection {
  final int fromIndex;
  final int toIndex;
  final AnimationController animationController;
  
  _ParticipantConnection({
    required this.fromIndex,
    required this.toIndex,
    required this.animationController,
  });
}

/// Painter for animated glowing connection lines
class _GlowingConnectionPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final double progress;
  final Color glowColor;
  final double circleRadius;
  
  _GlowingConnectionPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.glowColor,
    required this.circleRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    // Calculate direction vector
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance < circleRadius * 2) return; // Too close, no line needed
    
    // Normalize direction
    final dirX = dx / distance;
    final dirY = dy / distance;
    
    // Offset start point to edge of 'from' circle
    final adjustedFrom = Offset(
      from.dx + dirX * circleRadius,
      from.dy + dirY * circleRadius,
    );
    
    // Offset end point to edge of 'to' circle
    final adjustedTo = Offset(
      to.dx - dirX * circleRadius,
      to.dy - dirY * circleRadius,
    );
    
    // Calculate animated end point (line grows from adjusted 'from' to adjusted 'to')
    final currentEnd = Offset(
      adjustedFrom.dx + (adjustedTo.dx - adjustedFrom.dx) * progress,
      adjustedFrom.dy + (adjustedTo.dy - adjustedFrom.dy) * progress,
    );
    
    // Draw multiple layers for subtle glow effect
    // Outer glow (soft, subtle)
    final outerGlowPaint = Paint()
      ..color = glowColor.withOpacity(0.08 * progress)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(adjustedFrom, currentEnd, outerGlowPaint);
    
    // Middle glow
    final middleGlowPaint = Paint()
      ..color = glowColor.withOpacity(0.15 * progress)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(adjustedFrom, currentEnd, middleGlowPaint);
    
    // Core line (thin)
    final corePaint = Paint()
      ..color = glowColor.withOpacity(0.4 * progress)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(adjustedFrom, currentEnd, corePaint);
    
    // Bright center (very thin)
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.25 * progress)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(adjustedFrom, currentEnd, centerPaint);
    
    // Animated pulse dot at the leading edge (only during animation)
    if (progress < 1.0) {
      final pulsePaint = Paint()
        ..color = glowColor.withOpacity(0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(currentEnd, 3, pulsePaint);
      
      final pulseCorePaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentEnd, 1.5, pulseCorePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _GlowingConnectionPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.from != from || 
           oldDelegate.to != to;
  }
}

/// Painter for sacred geometry connecting lines
class _SacredGeometryPainter extends CustomPainter {
  final List<Offset> positions;
  final Color color;
  final int ringCount;

  _SacredGeometryPainter(this.positions, this.color, this.ringCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    if (positions.length < 7) return;

    // Connect first ring (inner) points to center
    for (int i = 1; i <= 6 && i < positions.length; i++) {
      canvas.drawLine(positions[0], positions[i], paint);
    }

    // Draw each ring's hexagon and connections
    for (int ring = 1; ring <= ringCount; ring++) {
      final ringStart = 1 + (ring - 1) * 6;
      final ringEnd = ringStart + 5;
      
      if (ringEnd >= positions.length) break;
      
      // Draw hexagon for this ring
      for (int i = ringStart; i <= ringEnd; i++) {
        final next = i == ringEnd ? ringStart : i + 1;
        canvas.drawLine(positions[i], positions[next], paint);
      }
      
      // Connect to previous ring (star pattern)
      if (ring > 1) {
        final prevRingStart = 1 + (ring - 2) * 6;
        for (int i = 0; i < 6; i++) {
          final currentIdx = ringStart + i;
          final prevIdx = prevRingStart + i;
          final prevNextIdx = prevRingStart + ((i + 1) % 6);
          
          if (currentIdx < positions.length && prevIdx < positions.length) {
            canvas.drawLine(positions[currentIdx], positions[prevIdx], paint);
          }
          if (currentIdx < positions.length && prevNextIdx < positions.length) {
            canvas.drawLine(positions[currentIdx], positions[prevNextIdx], paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SacredGeometryPainter oldDelegate) {
    return oldDelegate.ringCount != ringCount || oldDelegate.positions.length != positions.length;
  }
}
