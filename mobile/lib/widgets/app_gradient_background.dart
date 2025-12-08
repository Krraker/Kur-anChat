import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// A gradient background widget that mimics a warm glow effect
/// Similar to premium app backgrounds but using our green accent color
class AppGradientBackground extends StatelessWidget {
  final Widget child;
  
  const AppGradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Base dark color
        color: Color(0xFF0A0A0A),
      ),
      child: Stack(
        children: [
          // Top radial glow effect (green tinted)
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            child: Container(
              height: 450,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    GlobalAppStyle.accentColor.withOpacity(0.25),
                    GlobalAppStyle.accentColor.withOpacity(0.12),
                    GlobalAppStyle.accentColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Secondary subtle glow for depth
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    GlobalAppStyle.accentColor.withOpacity(0.08),
                    GlobalAppStyle.accentColor.withOpacity(0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // Very subtle bottom gradient for depth
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Child content
          child,
        ],
      ),
    );
  }
}
