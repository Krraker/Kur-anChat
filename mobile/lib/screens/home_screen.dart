import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/home/weekly_progress_section.dart';
import '../widgets/home/daily_journey_card.dart';
import '../widgets/home/islamic_calendar_banner.dart';
import '../widgets/home/calendar_popup.dart';
import 'onboarding/onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Track which card is expanded (null = none)
  CardType? _expandedCard;
  bool _isLoading = true;
  
  // Left side panel state (for K button menu)
  bool _isMenuPanelOpen = false;
  int _selectedMenuTab = 0; // 0 = Agenda, 1 = Settings (future)
  late AnimationController _panelAnimationController;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _panelFadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadDailyContent();
    
    // Initialize panel animation controller
    _panelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _panelSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    _panelFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _panelAnimationController.dispose();
    super.dispose();
  }
  
  void _toggleMenuPanel() {
    if (_isMenuPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isMenuPanelOpen = false);
      });
    } else {
      setState(() => _isMenuPanelOpen = true);
      _panelAnimationController.forward();
    }
  }
  
  void _closeMenuPanel() {
    if (_isMenuPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isMenuPanelOpen = false);
      });
    }
  }

  Future<void> _loadDailyContent() async {
    // Fetch daily content from API
    await DailyContent.fetchDailyContent();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCardExpansionChanged(CardType cardType, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedCard = cardType;
      } else if (_expandedCard == cardType) {
        _expandedCard = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Demo data - in real app this would come from state management
    const completedActivities = 2; // Out of 4
    const totalActivities = 4;
    const progress = completedActivities / totalActivities;
    
    final bool hasExpandedCard = _expandedCard != null;
    
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
        children: [
          // Scrollable content area
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 72,
              bottom: 160,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content that gets dimmed when card is expanded
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard ? 0.15 : 1.0,
                  child: const Column(
                    children: [
                      SizedBox(height: 20),
                
                // Weekly Progress Calendar
                      WeeklyProgressSection(
                  currentDayIndex: 6, // Sunday (demo)
                  completedDays: [true, true, false, false, false, false, false],
                  streakCount: 2,
                ),
                    ],
                  ),
                ),
                
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard ? 0.15 : 1.0,
                  child: const Column(
                    children: [
                      SizedBox(height: 24),
                
                // Daily Progress Bar
                DailyProgressBar(
                  progress: progress,
                  label: 'Bugünkü ilerleme',
                ),
                
                      SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Activity Cards - Expandable (these don't get dimmed when they're the expanded one)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard && _expandedCard != CardType.verse ? 0.15 : 1.0,
                  child: ExpandableDailyJourneyCard(
                  title: 'Günün Ayeti',
                  duration: '1 DK',
                  icon: Icons.auto_stories,
                    isCompleted: false,
                    cardType: CardType.verse,
                    onExpansionChanged: (isExpanded) => _onCardExpansionChanged(CardType.verse, isExpanded),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard && _expandedCard != CardType.tefsir ? 0.15 : 1.0,
                  child: ExpandableDailyJourneyCard(
                  title: 'Kişisel Tefsir',
                  duration: '2 DK',
                  icon: Icons.psychology,
                    isCompleted: false,
                    cardType: CardType.tefsir,
                    onExpansionChanged: (isExpanded) => _onCardExpansionChanged(CardType.tefsir, isExpanded),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard && _expandedCard != CardType.prayer ? 0.15 : 1.0,
                  child: ExpandableDailyJourneyCard(
                  title: 'Günün Duası',
                  duration: '1 DK',
                  icon: Icons.favorite_border,
                  isCompleted: false,
                    cardType: CardType.prayer,
                    onExpansionChanged: (isExpanded) => _onCardExpansionChanged(CardType.prayer, isExpanded),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Content below cards gets dimmed
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: hasExpandedCard ? 0.15 : 1.0,
                  child: const Column(
                    children: [
                      DailyRewardCard(
                  isLocked: true,
                ),
                
                      SizedBox(height: 24),
                
                // Divider with crescent moon
                      IconDivider(
                  icon: Icons.nightlight_round,
                ),
                
                      SizedBox(height: 16),
                
                // Islamic Calendar Banner
                      IslamicCalendarBanner(
                  hijriDay: 5,
                  hijriMonth: 'Cemaziyelahir',
                  hijriYear: 1446,
                  // specialEvent: 'Cuma', // Uncomment for special events
                ),
                
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Top gradient overlay with blur
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 72,
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
          
          // Top content (Header) on top of blur
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
                  // Profile Avatar / Menu Button (Tap to open menu, Long press to reset onboarding)
                  GestureDetector(
                    onTap: _toggleMenuPanel,
                    onLongPress: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', false);
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
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
                  ),
                  
                  const SizedBox(width: 14),
                  
                  // Title - Flexible to prevent overflow
                  Flexible(
                    child: Text(
                      'Günün Yolculuğu',
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Streak Counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                        SvgPicture.asset(
                          'assets/UI/ICONS/fireicon.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFB74D),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2',
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Divider
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Calendar Icon - constrained to prevent overflow
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                      onPressed: () {
                        CalendarPopup.show(context);
                      },
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
          
          // Left side menu panel (Holy Agenda, etc.)
          if (_isMenuPanelOpen) ...[
            // Backdrop - tap to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenuPanel,
                child: FadeTransition(
                  opacity: _panelFadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            
            // The slide-in panel from left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SlideTransition(
                position: _panelSlideAnimation,
                child: _buildMenuPanel(),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
  
  Widget _buildMenuPanel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.80; // 80% of screen width
    final topPadding = MediaQuery.of(context).padding.top;
    
    return SizedBox(
      width: panelWidth + 28, // Extra space for the edge button
      child: Stack(
        children: [
          // Main panel
          Container(
            width: panelWidth,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(10, 0),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header with title
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 20, right: 16, top: topPadding + 20, bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // K Logo
                            Container(
                              width: 36,
                              height: 36,
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
                            Text(
                              'Kur\'an Chat',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Tab selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            _buildTabButton('Takvim', 0, Icons.event),
                            const SizedBox(width: 8),
                            _buildTabButton('Hakkında', 1, Icons.info_outline),
                          ],
                        ),
                      ),
                      
                      // Content based on selected tab
                      Expanded(
                        child: _selectedMenuTab == 0
                            ? _buildAgendaContent()
                            : _buildAboutContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Minimize arrow button on the right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: const Alignment(0, 0.15),
              child: GestureDetector(
                onTap: _closeMenuPanel,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
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
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white.withOpacity(0.9),
                          size: 28,
                        ),
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
  
  Widget _buildTabButton(String label, int tabIndex, IconData icon) {
    final isSelected = _selectedMenuTab == tabIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenuTab = tabIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? GlobalAppStyle.accentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? GlobalAppStyle.accentColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? GlobalAppStyle.accentColor
                  : Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? GlobalAppStyle.accentColor
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgendaContent() {
    // Islamic calendar events - Holy days, holidays, and special occasions
    final List<Map<String, dynamic>> upcomingEvents = [
      {
        'name': 'Cuma',
        'date': 'Her Hafta',
        'description': 'Haftalık mübarek gün',
        'icon': Icons.mosque,
        'isWeekly': true,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Mevlid Kandili',
        'hijriDate': '12 Rebiülevvel 1446',
        'date': '15 Eylül 2024',
        'description': 'Peygamberimizin doğumu',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFFFB74D),
      },
      {
        'name': 'Regaip Kandili',
        'hijriDate': '1 Recep 1446',
        'date': '2 Ocak 2025',
        'description': 'Recep ayının ilk cuması',
        'icon': Icons.nights_stay,
        'color': const Color(0xFF64B5F6),
      },
      {
        'name': 'Miraç Kandili',
        'hijriDate': '27 Recep 1446',
        'date': '28 Ocak 2025',
        'description': 'İsra ve Miraç gecesi',
        'icon': Icons.flight_takeoff,
        'color': const Color(0xFF9575CD),
      },
      {
        'name': 'Berat Kandili',
        'hijriDate': '15 Şaban 1446',
        'date': '14 Şubat 2025',
        'description': 'Günahların affedildiği gece',
        'icon': Icons.favorite,
        'color': const Color(0xFFE91E63),
      },
      {
        'name': 'Ramazan Başlangıcı',
        'hijriDate': '1 Ramazan 1446',
        'date': '1 Mart 2025',
        'description': 'Oruç ayının başlangıcı',
        'icon': Icons.nightlight_round,
        'color': const Color(0xFF26A69A),
      },
      {
        'name': 'Kadir Gecesi',
        'hijriDate': '27 Ramazan 1446',
        'date': '27 Mart 2025',
        'description': 'Bin aydan hayırlı gece',
        'icon': Icons.star,
        'color': const Color(0xFFFFC107),
      },
      {
        'name': 'Ramazan Bayramı',
        'hijriDate': '1-3 Şevval 1446',
        'date': '30 Mart - 1 Nisan 2025',
        'description': 'Fıtır Bayramı',
        'icon': Icons.celebration,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Kurban Bayramı',
        'hijriDate': '10-13 Zilhicce 1446',
        'date': '6-9 Haziran 2025',
        'description': 'Kurban Bayramı',
        'icon': Icons.volunteer_activism,
        'color': const Color(0xFFFF7043),
      },
      {
        'name': 'Aşure Günü',
        'hijriDate': '10 Muharrem 1447',
        'date': '16 Temmuz 2025',
        'description': 'Muharrem ayının onuncu günü',
        'icon': Icons.water_drop,
        'color': const Color(0xFF78909C),
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 120, left: 16, right: 16),
      itemCount: upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = upcomingEvents[index];
        final isWeekly = event['isWeekly'] == true;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (event['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    event['icon'] as IconData,
                    color: event['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isWeekly && event['hijriDate'] != null)
                        Text(
                          event['hijriDate'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: GlobalAppStyle.accentColor.withOpacity(0.9),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        event['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kur\'an Chat Hakkında',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kur\'an Chat, İslami değerleri dijital dünyada yaşatmak için tasarlanmış bir uygulamadır. '
            'Günlük ayetler, dualar ve tefsirlerle manevi yolculuğunuza rehberlik eder.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: GlobalAppStyle.accentColor.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Versiyon 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
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
