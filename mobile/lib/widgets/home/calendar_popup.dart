import 'dart:ui';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class CalendarPopup extends StatefulWidget {
  const CalendarPopup({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Calendar',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CalendarPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
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
                  _buildHeader(),
                  
                  // Weekday labels
                  _buildWeekdayLabels(),
                  
                  // Calendar grid
                  _buildCalendarGrid(),
                  
                  // Footer with Hijri date
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 28,
            ),
            onPressed: _previousMonth,
          ),
          Text(
            '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 28,
            ),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == 'Cmt' || day == 'Paz';
          return SizedBox(
            width: 36,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWeekend 
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Monday = 1, Sunday = 7. We want Monday as first day.
    int startWeekday = firstDayOfMonth.weekday; // 1 = Monday
    
    final today = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year && today.month == _currentMonth.month;

    List<Widget> dayWidgets = [];
    
    // Add empty spaces for days before the first day of month
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }
    
    // Add day numbers
    for (int day = 1; day <= daysInMonth; day++) {
      final isToday = isCurrentMonth && day == today.day;
      final isSelected = _selectedDate.year == _currentMonth.year &&
          _selectedDate.month == _currentMonth.month &&
          _selectedDate.day == day;
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, day);
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? GlobalAppStyle.accentColor
                  : isToday
                      ? GlobalAppStyle.accentColor.withOpacity(0.2)
                      : Colors.transparent,
              border: isToday && !isSelected
                  ? Border.all(
                      color: GlobalAppStyle.accentColor,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? GlobalAppStyle.accentColor
                          : Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: (MediaQuery.of(context).size.width - 48 - 36 * 7) / 6,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildFooter() {
    // Simple Hijri date approximation (for demo purposes)
    // In production, use a proper Hijri calendar library
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hijri date
          Row(
            children: [
              Icon(
                Icons.brightness_3_rounded,
                size: 16,
                color: GlobalAppStyle.accentColor.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                '5 Cemaziyelahir 1446',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          // Today button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = DateTime.now();
                _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: GlobalAppStyle.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: GlobalAppStyle.accentColor.withOpacity(0.4),
                ),
              ),
              child: Text(
                'Bugün',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: GlobalAppStyle.accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
