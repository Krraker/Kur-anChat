import 'dart:ui';
import 'package:flutter/material.dart';

export 'liquid_glass_pill.dart';

/// Global app style configuration for liquid glass effects
class GlobalAppStyle {
  GlobalAppStyle._();

  /// Primary font family - OggText
  static const String fontFamily = 'OggText';

  /// Primary accent color - Islamic Green (deeper, more traditional)
  static const Color accentColor = Color(0xFF00A86B); // Jade/Islamic green
  
  /// Secondary accent - lighter variant
  static const Color accentColorLight = Color(0xFF4DC591);
  
  /// Gold accent for highlights
  static const Color goldAccent = Color(0xFFD4AF37);
  
  /// Primary glass tint color
  static const Color glassTint = Colors.white;
  
  /// Shadow color for depth effects
  static const Color shadowColor = Colors.black;
  
  /// Text styles using OggText
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 57,
    letterSpacing: -0.25,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 45,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 36,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 32,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 28,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 24,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 22,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    letterSpacing: 0.15,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.25,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.4,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.5,
  );
}

/// Variants for liquid glass intensity
enum LiquidGlassVariant {
  subtle,
  standard,
  intense,
  frosted,
}

// ===========================================
// LIQUID GLASS WIDGETS - SIMPLIFIED
// ===========================================

/// A liquid glass card widget with frosted glass effect
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? padding;
  final LiquidGlassVariant variant;
  final Color? borderColor;
  final double borderWidth;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.padding,
    this.variant = LiquidGlassVariant.standard,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final (baseBlur, tintOpacity, shadowOpacity) = _getVariantValues();
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: baseBlur, sigmaY: baseBlur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.white.withOpacity(tintOpacity * 0.5),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.25),
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(tintOpacity),
                  Colors.white.withOpacity(tintOpacity * 0.3),
                  Colors.white.withOpacity(tintOpacity * 0.1),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  (double, double, double) _getVariantValues() {
    switch (variant) {
      case LiquidGlassVariant.subtle:
        return (20.0, 0.08, 0.15);
      case LiquidGlassVariant.standard:
        return (35.0, 0.12, 0.18);
      case LiquidGlassVariant.intense:
        return (50.0, 0.18, 0.22);
      case LiquidGlassVariant.frosted:
        return (70.0, 0.25, 0.18);
    }
  }
}

/// A liquid glass chip widget for tags and small interactive elements
class LiquidGlassChip extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;

  const LiquidGlassChip({
    super.key,
    required this.child,
    this.height = 48,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.onTap,
    this.borderColor,
    this.borderWidth = 1.5,
    this.blurSigma = 25,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? GlobalAppStyle.accentColor.withOpacity(0.4);
    final chipRadius = height / 2;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(chipRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(chipRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(chipRadius),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: effectiveBorderColor,
                  width: borderWidth,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A liquid glass button widget
class LiquidGlassButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.height = 56,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.onTap,
    this.borderRadius = 20,
    this.borderColor,
    this.borderWidth = 1.5,
    this.blurSigma = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: borderColor ?? Colors.white.withOpacity(0.25),
                  width: borderWidth,
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
              child: Center(
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A liquid glass navigation bar widget
class LiquidGlassNavigationBar extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;
  final EdgeInsets margin;
  final double blurSigma;

  const LiquidGlassNavigationBar({
    super.key,
    required this.child,
    this.height = 70,
    this.borderRadius = 20,
    this.margin = const EdgeInsets.only(left: 20, right: 20, bottom: 20),
    this.blurSigma = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SafeArea(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
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
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
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
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A liquid glass list item / row widget
class LiquidGlassListItem extends StatelessWidget {
  final Widget child;
  final double? height;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double blurSigma;

  const LiquidGlassListItem({
    super.key,
    required this.child,
    this.height,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.blurSigma = 25,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: borderColor ?? Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
