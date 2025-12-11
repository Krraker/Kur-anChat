import 'dart:ui';
import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  // Track which card is expanded (null = none)
  CardType? _expandedCard;

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
          
          // Top content (Header) on top of blur
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  // Profile Avatar (Long press to reset onboarding)
                  GestureDetector(
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
                  
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Günün Yolculuğu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Manevi Gelişim',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
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
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Color(0xFFFFB74D),
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
        ],
        ),
      ),
    );
  }

}
