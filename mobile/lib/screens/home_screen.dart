import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/home/weekly_progress_section.dart';
import '../widgets/home/daily_journey_card.dart';
import '../widgets/home/islamic_calendar_banner.dart';
import '../widgets/home/calendar_popup.dart';
import '../services/daily_content_service.dart';
import 'onboarding/onboarding_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Track which card is expanded (null = none)
  CardType? _expandedCard;
  bool _isLoading = true;
  
  // Left side panel state (for K button menu)
  bool _isMenuPanelOpen = false;
  int _selectedMenuTab = 0; // 0 = Agenda, 1 = Settings (future)
  late AnimationController _panelAnimationController;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _panelFadeAnimation;
  
  // Calendar event expansion state - allows multiple expanded
  final Set<int> _expandedEventIndices = {};
  final Map<int, AnimationController> _eventExpandControllers = {};
  final Map<int, Animation<double>> _eventExpandAnimations = {};

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
    for (final controller in _eventExpandControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  AnimationController _getOrCreateController(int index) {
    if (!_eventExpandControllers.containsKey(index)) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
      _eventExpandControllers[index] = controller;
      _eventExpandAnimations[index] = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCubic,
      );
    }
    return _eventExpandControllers[index]!;
  }
  
  void _toggleEventExpansion(int index) {
    final controller = _getOrCreateController(index);
    
    if (_expandedEventIndices.contains(index)) {
      controller.reverse().then((_) {
        setState(() => _expandedEventIndices.remove(index));
      });
    } else {
      setState(() => _expandedEventIndices.add(index));
      controller.forward(from: 0.0);
    }
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
    final service = DailyContentService();
    await service.getDailyContent();
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
          
          // Top gradient overlay with blur - MASTER LAYER (Darker/Closer)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.75), // DARKER for closer feel
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.30),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.12),
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
                  // Menu Button (Tap to open menu, Long press to reset onboarding)
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
                    child: SvgPicture.asset(
                      'assets/icons/HamburgerMenu.svg',
                      width: 40,
                      height: 40,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 14),
                  
                  // Title
                  Text(
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
                  ),
                  
                  const Spacer(),
                  
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
                  
                  // Calendar Icon
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 22,
                    ),
                    onPressed: () {
                      CalendarPopup.show(context);
                    },
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
    final panelWidth = screenWidth * 0.75; // Match Sohbetler width
    final topPadding = MediaQuery.of(context).padding.top + 110;
    
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
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  // SECONDARY LAYER - Lighter for further depth
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25), // LIGHTER base
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.12),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.15), // LIGHTER gradient
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.04),
                          Colors.white.withOpacity(0.02),
                        ],
                        stops: const [0.0, 0.15, 0.4, 1.0],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with title - glassmorphism
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(left: 16, right: 16, top: topPadding - 95, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.5,
                              ),
                            ),
                          ),
                        child: Text(
                          'Kur\'an Chat',
                          style: TextStyle(
                            fontSize: 28,
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
                      ),
                      
                      // Tab selector area - darker glassmorphism
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton('Takvim', 0),
                            const SizedBox(width: 20),
                            _buildTabButton('Hakkında', 1),
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
  
  Widget _buildTabButton(String label, int tabIndex) {
    final isSelected = _selectedMenuTab == tabIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenuTab = tabIndex;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }
  
  // Helper function to calculate days until event
  int _daysUntilEvent(DateTime eventDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final event = DateTime(eventDate.year, eventDate.month, eventDate.day);
    return event.difference(today).inDays;
  }
  
  // Helper function to format days until
  String _formatDaysUntil(int days) {
    if (days == 0) return 'Bugün';
    if (days == 1) return 'Yarın';
    if (days < 0) return 'Geçti';
    return '$days gün';
  }
  
  Widget _buildAgendaContent() {
    // Islamic calendar events - Holy days, holidays, and special occasions for 2026
    final List<Map<String, dynamic>> upcomingEvents = [
      {
        'name': 'Cuma',
        'subtitle': 'Her Hafta',
        'description': 'Haftalık mübarek gün',
        'isWeekly': true,
        'eventDate': _getNextFriday(),
        'details': [
          'Cuma namazına hazırlık',
          'Kehf suresini okuma',
          'Bol bol salavat getirme',
          'Güzel giyinme ve temizlik',
        ],
      },
      {
        'name': 'Regaip Kandili',
        'subtitle': '1 Recep 1447',
        'description': 'Recep ayının ilk cuması',
        'eventDate': DateTime(2025, 12, 26),
        'details': [
          'Kaza namazları kılma',
          'Tövbe ve istiğfar',
          'Kuran-ı Kerim okuma',
          'Dua ve zikir',
        ],
      },
      {
        'name': 'Miraç Kandili',
        'subtitle': '27 Recep 1447',
        'description': 'İsra ve Miraç gecesi',
        'eventDate': DateTime(2026, 1, 16),
        'details': [
          'Miraç hadisesini okuma',
          'Nafile namazlar kılma',
          'Beş vakit namazın farziyeti',
          'Dua ve tefekkür',
        ],
      },
      {
        'name': 'Berat Kandili',
        'subtitle': '15 Şaban 1447',
        'description': 'Günahların affedildiği gece',
        'eventDate': DateTime(2026, 2, 1),
        'details': [
          'Tövbe ve istiğfar',
          'Geçmiş günahlar için af dileme',
          'Nafile namazlar',
          'Kuran okuma ve dua',
        ],
      },
      {
        'name': 'Ramazan Başlangıcı',
        'subtitle': '1 Ramazan 1447',
        'description': 'Oruç ayının başlangıcı',
        'eventDate': DateTime(2026, 2, 17),
        'details': [
          'Sahura kalkmaya hazırlık',
          'Niyet etme',
          'Teravih namazları',
          'Kuran hatmi planı',
        ],
      },
      {
        'name': 'Kadir Gecesi',
        'subtitle': '27 Ramazan 1447',
        'description': 'Bin aydan hayırlı gece',
        'eventDate': DateTime(2026, 3, 14),
        'details': [
          'Gece boyu ibadet',
          'Kuran okuma',
          'Dua ve yakarış',
          'Tövbe ve istiğfar',
        ],
      },
      {
        'name': 'Ramazan Bayramı',
        'subtitle': '1-3 Şevval 1447',
        'description': 'Fıtır Bayramı',
        'eventDate': DateTime(2026, 3, 19),
        'details': [
          'Fıtır sadakası vermek',
          'Bayram namazı',
          'Akraba ziyaretleri',
          'Sevinç ve şükür',
        ],
      },
      {
        'name': 'Kurban Bayramı',
        'subtitle': '10-13 Zilhicce 1447',
        'description': 'Kurban Bayramı',
        'eventDate': DateTime(2026, 5, 26),
        'details': [
          'Kurban kesimi',
          'Bayram namazı',
          'Et dağıtımı',
          'Akraba ve komşu ziyaretleri',
        ],
      },
      {
        'name': 'Aşure Günü',
        'subtitle': '10 Muharrem 1448',
        'description': 'Muharrem ayının onuncu günü',
        'eventDate': DateTime(2026, 7, 5),
        'details': [
          'Oruç tutma',
          'Aşure yapma ve dağıtma',
          'Hz. Hüseyin\'i anma',
          'Dua ve zikir',
        ],
      },
    ];
    
    // Sort by closest date
    upcomingEvents.sort((a, b) {
      final daysA = _daysUntilEvent(a['eventDate'] as DateTime);
      final daysB = _daysUntilEvent(b['eventDate'] as DateTime);
      return daysA.compareTo(daysB);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 120),
      itemCount: upcomingEvents.length,
      itemBuilder: (context, index) {
        final event = upcomingEvents[index];
        final isExpanded = _expandedEventIndices.contains(index);
        final daysUntil = _daysUntilEvent(event['eventDate'] as DateTime);
        final daysText = _formatDaysUntil(daysUntil);
        final isClosest = index == 0 && daysUntil >= 0;
        
        return _buildEventItem(
          event: event,
          index: index,
          isExpanded: isExpanded,
          daysText: daysText,
          isClosest: isClosest,
        );
      },
    );
  }
  
  DateTime _getNextFriday() {
    final now = DateTime.now();
    final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    return now.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
  }
  
  Widget _buildEventItem({
    required Map<String, dynamic> event,
    required int index,
    required bool isExpanded,
    required String daysText,
    required bool isClosest,
  }) {
    final details = event['details'] as List<String>;
    _getOrCreateController(index); // Ensure controller exists
    final animation = _eventExpandAnimations[index]!;
    
    return GestureDetector(
      onTap: () => _toggleEventExpansion(index),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final animValue = animation.value;
          
          // When collapsed - simple row like Sohbetler
          if (!isExpanded && animValue == 0) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.08),
                    width: 0.5,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event['description'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          daysText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Expanded state - lighter background with all content
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // Lighter background when expanded
              color: Colors.white.withOpacity(0.06 * animValue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['name'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            daysText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Expandable details section
                ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    heightFactor: animValue,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bu günde yapılabilecekler:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...details.asMap().entries.map((entry) {
                            final itemIndex = entry.key;
                            final detail = entry.value;
                            
                            // Staggered animation delay
                            final delayFactor = itemIndex * 0.08;
                            final itemAnimValue = ((animValue - delayFactor) / (1 - delayFactor)).clamp(0.0, 1.0);
                            
                            return Opacity(
                              opacity: itemAnimValue,
                              child: Transform.translate(
                                offset: Offset(0, (1 - itemAnimValue) * 4),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 3,
                                        margin: const EdgeInsets.only(top: 6, right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detail,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.6),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom separator line
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(top: 4),
                color: Colors.white.withOpacity(0.08),
              ),
            ],
          ),
        );
      },
    ),
  );
}
  
  Widget _buildAboutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hakkında',
            style: TextStyle(
              fontSize: 20,
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Text(
              'Bu uygulama, Kur\'an-ı Kerim ayetlerinin anlamını kavramaya yardımcı olmak amacıyla tasarlanmış bilgilendirici bir dijital yardımcıdır. Sunulan içerikler; klasik tefsirler ve güvenilir İslami kaynaklarda yer alan açıklamaların özetlenmesi, sadeleştirilmesi ve yorumlayıcı olmayan bir biçimde aktarılması yoluyla oluşturulmaktadır.\n\n'
              'Uygulama; fetva verme, dini hüküm bildirme, dini karar alma, ibadet şekilleri belirleme veya kişisel dini sorumluluklara dair yönlendirme amacı taşımaz ve bu konularda herhangi bir otorite iddiasında bulunmaz. Uygulama tarafından sağlanan tüm bilgiler genel bilgilendirme amaçlıdır ve bağlayıcı dini hüküm niteliği taşımaz.\n\n'
              'Dini ibadetler, fıkhî meseleler, kişisel veya özel durumlara ilişkin dini konular için yetkin İslam âlimlerine, resmi dini kurumlara veya alanında uzman kişilere danışılması gerekmektedir. Bu uygulama, bu tür konularda nihai karar mercii değildir.\n\n'
              'Bu uygulama, Kur\'an-ı Kerim\'in anlaşılmasını destekleyen yardımcı bir araç olarak sunulmakta olup, dini otorite, fetva makamı veya rehberlik hizmeti olarak değerlendirilmemelidir.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
                height: 1.7,
              ),
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
                  color: Colors.white.withOpacity(0.5),
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
