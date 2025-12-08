import 'dart:ui';
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

/// A banner displaying Islamic (Hijri) calendar information
class IslamicCalendarBanner extends StatelessWidget {
  final int hijriDay;
  final String hijriMonth;
  final int hijriYear;
  final String? specialEvent; // e.g., "Ramazan", "Muharrem"

  const IslamicCalendarBanner({
    super.key,
    this.hijriDay = 5,
    this.hijriMonth = 'Cemaziyelahir',
    this.hijriYear = 1446,
    this.specialEvent,
  });

  // Hijri month names in Turkish
  static const List<String> hijriMonths = [
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GlobalAppStyle.accentColor.withOpacity(0.25),
                  GlobalAppStyle.accentColor.withOpacity(0.12),
                  GlobalAppStyle.accentColor.withOpacity(0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: GlobalAppStyle.accentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Decorative crescent moon
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GlobalAppStyle.accentColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.nightlight_round,
                          size: 28,
                          color: GlobalAppStyle.accentColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Decorative stars
                Positioned(
                  right: 30,
                  top: 20,
                  child: Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  right: 50,
                  bottom: 25,
                  child: Icon(
                    Icons.star,
                    size: 10,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 35,
                  child: Icon(
                    Icons.star,
                    size: 8,
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Special event label if any
                      if (specialEvent != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GlobalAppStyle.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialEvent!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: GlobalAppStyle.accentColor,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Main date display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$hijriDay',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hijriMonth,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.95),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '$hijriYear H',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal divider with an icon in the center
class IconDivider extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;

  const IconDivider({
    super.key,
    this.icon = Icons.nightlight_round,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              icon,
              color: iconColor ?? Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

