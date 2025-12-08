import 'dart:ui';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

/// A card widget for daily journey activities (Verse, Devotional, Prayer, Reward)
class DailyJourneyCard extends StatelessWidget {
  final String title;
  final String duration;
  final IconData icon;
  final bool isCompleted;
  final bool isLocked;
  final bool isExpandable;
  final VoidCallback? onTap;
  final Widget? trailingWidget;
  final Color? accentColor;

  const DailyJourneyCard({
    super.key,
    required this.title,
    required this.duration,
    required this.icon,
    this.isCompleted = false,
    this.isLocked = false,
    this.isExpandable = false,
    this.onTap,
    this.trailingWidget,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? GlobalAppStyle.accentColor;
    
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isCompleted 
                      ? effectiveAccentColor.withOpacity(0.4)
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icon / Checkbox area
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? effectiveAccentColor.withOpacity(0.2)
                            : isLocked 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCompleted || isLocked
                            ? null
                            : Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted 
                              ? Icons.check_rounded 
                              : isLocked 
                                  ? Icons.lock_outline 
                                  : icon,
                          color: isCompleted 
                              ? effectiveAccentColor
                              : Colors.white.withOpacity(isLocked ? 0.5 : 0.85),
                          size: 18,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 14),
                    
                    // Title and duration
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white.withOpacity(isLocked ? 0.5 : 0.95),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          if (duration.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              duration,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(isLocked ? 0.4 : 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Trailing widget (DONE label or expand icon)
                    if (trailingWidget != null)
                      trailingWidget!
                    else if (isCompleted)
                      Text(
                        'TAMAMLANDI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: effectiveAccentColor,
                        ),
                      )
                    else if (isExpandable)
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 24,
                      )
                    else if (!isLocked)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 22,
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
}

/// A special reward card with decorative element
class DailyRewardCard extends StatelessWidget {
  final bool isLocked;
  final VoidCallback? onTap;

  const DailyRewardCard({
    super.key,
    this.isLocked = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: GlobalAppStyle.accentColor.withOpacity(0.15),
                border: Border.all(
                  color: GlobalAppStyle.accentColor.withOpacity(0.3),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GlobalAppStyle.accentColor.withOpacity(0.2),
                    GlobalAppStyle.accentColor.withOpacity(0.08),
                    GlobalAppStyle.accentColor.withOpacity(0.04),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative crescent moon
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: GlobalAppStyle.accentColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  // Content - centered vertically
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Lock icon
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                isLocked ? Icons.lock_outline : Icons.card_giftcard,
                                color: Colors.white.withOpacity(isLocked ? 0.5 : 0.9),
                                size: 18,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 14),
                          
                          // Title
                          Text(
                            "GÜNÜN ÖDÜLÜ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white.withOpacity(isLocked ? 0.6 : 0.95),
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

