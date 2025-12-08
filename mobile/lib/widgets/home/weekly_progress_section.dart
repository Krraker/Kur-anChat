import 'dart:ui';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

/// Weekly progress calendar showing days of the week with completion status
class WeeklyProgressSection extends StatelessWidget {
  final int currentDayIndex; // 0 = Monday (Pazartesi)
  final List<bool> completedDays; // Which days are completed
  final int streakCount;

  const WeeklyProgressSection({
    super.key,
    this.currentDayIndex = 6, // Default to Sunday for demo
    this.completedDays = const [true, true, false, false, false, false, false],
    this.streakCount = 0,
  });

  // Turkish day abbreviations
  static const List<String> dayLabels = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
  static const List<String> fullDayNames = [
    'Pazartesi',
    'Salı', 
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return SizedBox(
                width: 44,
                child: Center(
                  child: Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: index == currentDayIndex
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
              final isCompleted = index < completedDays.length && completedDays[index];
              final isCurrent = index == currentDayIndex;
              final dayNumber = index + 1;
              
              return _DayCircle(
                dayNumber: dayNumber,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                hasStreak: isCompleted && index > 0 && 
                    (index - 1 < completedDays.length && completedDays[index - 1]),
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
  final bool hasStreak;

  const _DayCircle({
    required this.dayNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.hasStreak,
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
                color: accentColor,
                width: 2,
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
            ? const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 22,
              )
            : Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCurrent 
                      ? accentColor
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

