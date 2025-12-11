import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../styles/styles.dart';

/// Weekly progress calendar showing days of the week with completion status
/// Now swipeable to navigate between weeks
class WeeklyProgressSection extends StatefulWidget {
  final int currentDayIndex; // 0 = Monday (Pazartesi)
  final List<bool> completedDays; // Which days are completed
  final int streakCount;

  const WeeklyProgressSection({
    super.key,
    this.currentDayIndex = 6, // Default to Sunday for demo
    this.completedDays = const [true, true, false, false, false, false, false],
    this.streakCount = 0,
  });

  @override
  State<WeeklyProgressSection> createState() => _WeeklyProgressSectionState();
}

class _WeeklyProgressSectionState extends State<WeeklyProgressSection> {
  late PageController _pageController;
  int _currentWeekOffset = 0; // 0 = this week, -1 = last week, 1 = next week

  // Turkish day abbreviations
  static const List<String> dayLabels = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 50); // Start in middle for infinite scroll feel
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get the Monday of a specific week offset
  DateTime _getWeekStart(int weekOffset) {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    return monday.add(Duration(days: weekOffset * 7));
  }

  // Check if a day is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if a day is in the past
  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Swipeable week view
        SizedBox(
          height: 90,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                _currentWeekOffset = page - 50;
              });
            },
            itemBuilder: (context, pageIndex) {
              final weekOffset = pageIndex - 50;
              return _buildWeekView(weekOffset);
            },
          ),
        ),
        
        // Week indicator dots
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWeekIndicator(-1),
            const SizedBox(width: 6),
            _buildWeekIndicator(0),
            const SizedBox(width: 6),
            _buildWeekIndicator(1),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekIndicator(int offset) {
    final isActive = _currentWeekOffset == offset;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isActive 
            ? GlobalAppStyle.accentColor
            : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildWeekView(int weekOffset) {
    final weekStart = _getWeekStart(weekOffset);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final isToday = _isToday(date);
              
              return SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
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
            }),
          ),
          
          const SizedBox(height: 8),
          
          // Day circles row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final isToday = _isToday(date);
              final isPast = _isPast(date);
              
              // For demo: completed days are past days in the current week
              final isCompleted = weekOffset == 0 
                  ? (index < widget.completedDays.length && widget.completedDays[index])
                  : (weekOffset < 0 ? true : false); // Past weeks all complete, future all incomplete
              
              return _DayCircle(
                dayNumber: date.day,
                isCompleted: isCompleted && isPast,
                isCurrent: isToday,
                isPast: isPast,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final int dayNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPast;

  const _DayCircle({
    required this.dayNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = GlobalAppStyle.accentColor;
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted 
            ? accentColor.withOpacity(0.9)
            : isCurrent
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
        border: isCurrent && !isCompleted
            ? Border.all(
                color: accentColor.withOpacity(0.8),
                width: 1,
              )
            : null,
        boxShadow: isCompleted || isCurrent
            ? [
                BoxShadow(
                  color: isCompleted 
                      ? accentColor.withOpacity(0.3)
                      : accentColor.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: isCompleted ? 2 : 0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? SvgPicture.asset(
                'assets/icons/allah_icon.svg',
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              )
            : Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCurrent 
                      ? accentColor
                      : isPast
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.7),
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
}

/// Daily progress bar showing completion percentage
class DailyProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;

  const DailyProgressBar({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    const accentColor = GlobalAppStyle.accentColor;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ?? 'Bugünkü ilerleme',
                style: TextStyle(
                  fontSize: 15,
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
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
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
          
          const SizedBox(height: 10),
          
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.15),
            ),
            child: Stack(
              children: [
                // Filled portion
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
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
