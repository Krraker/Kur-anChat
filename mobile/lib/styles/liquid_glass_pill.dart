import 'dart:ui';
import 'package:flutter/material.dart';

/// Configuration for an inner shadow effect
class InnerShadowConfig {
  final Offset offset;
  final double blurRadius;
  final double spreadRadius;
  final Color color;

  const InnerShadowConfig({
    required this.offset,
    required this.blurRadius,
    this.spreadRadius = 0,
    required this.color,
  });
}

/// Custom painter for rendering inner shadows on a rounded rectangle
class InnerShadowPainter extends CustomPainter {
  final List<InnerShadowConfig> shadows;
  final double borderRadius;
  final Color? fillColor;

  InnerShadowPainter({
    required this.shadows,
    required this.borderRadius,
    this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Fill the base shape if fillColor is provided
    if (fillColor != null) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    // Clip to the rounded rectangle
    canvas.save();
    canvas.clipRRect(rrect);

    // Draw each inner shadow
    for (final shadow in shadows) {
      // Create an expanded rect for the shadow source (outside the visible area)
      final shadowRect = Rect.fromLTWH(
        -shadow.blurRadius * 2 - shadow.spreadRadius + shadow.offset.dx,
        -shadow.blurRadius * 2 - shadow.spreadRadius + shadow.offset.dy,
        size.width + shadow.blurRadius * 4 + shadow.spreadRadius * 2,
        size.height + shadow.blurRadius * 4 + shadow.spreadRadius * 2,
      );

      // Create a path that represents the area OUTSIDE the inner shape
      final outerPath = Path()..addRect(shadowRect);
      
      // The inner cutout - slightly adjusted for spread
      final innerRect = Rect.fromLTWH(
        shadow.spreadRadius,
        shadow.spreadRadius,
        size.width - shadow.spreadRadius * 2,
        size.height - shadow.spreadRadius * 2,
      );
      final innerRRect = RRect.fromRectAndRadius(
        innerRect,
        Radius.circular(borderRadius - shadow.spreadRadius),
      );
      
      outerPath.addRRect(innerRRect);
      outerPath.fillType = PathFillType.evenOdd;

      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);

      canvas.drawPath(outerPath, shadowPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter oldDelegate) {
    return shadows != oldDelegate.shadows ||
        borderRadius != oldDelegate.borderRadius ||
        fillColor != oldDelegate.fillColor;
  }
}

/// Configuration for blur values
class BlurConfig {
  final double layerBlur;
  final double backgroundBlur;
  final double opacity;
  final EdgeInsets padding;

  const BlurConfig({
    required this.layerBlur,
    required this.backgroundBlur,
    required this.opacity,
    required this.padding,
  });
}

/// A liquid glass / frosted glass pill-shaped component
/// 
/// This widget creates a sophisticated glass-morphism effect with:
/// - Multiple layered blurred rectangles
/// - Inner shadows for depth
/// - Soft outer shadow
/// 
/// Usage:
/// ```dart
/// LiquidGlassPill(
///   width: 300,
///   height: 200,
///   child: Center(child: Text('Hello')),
/// )
/// ```
class LiquidGlassPill extends StatelessWidget {
  /// The width of the pill. If null, uses constraints from parent.
  final double? width;

  /// The height of the pill. If null, uses constraints from parent.
  final double? height;

  /// The child widget to display inside the pill.
  final Widget? child;

  /// Base background blur sigma (default: 50)
  final double baseBackgroundBlur;

  /// Blur configs for the 3 layered rectangles (largest to smallest)
  final List<BlurConfig>? layerConfigs;

  /// Inner shadow configs for the top highlight layer
  final List<InnerShadowConfig>? highlightShadows;

  /// Bottom shadow blur sigma (default: 74)
  final double bottomShadowBlur;

  /// Bottom shadow opacity (default: 0.25)
  final double bottomShadowOpacity;

  /// Top highlight fill opacity (default: 0.10)
  final double highlightOpacity;

  /// Base layer fill opacity (default: 0.01)
  final double baseOpacity;

  const LiquidGlassPill({
    super.key,
    this.width,
    this.height,
    this.child,
    this.baseBackgroundBlur = 50,
    this.layerConfigs,
    this.highlightShadows,
    this.bottomShadowBlur = 74,
    this.bottomShadowOpacity = 0.25,
    this.highlightOpacity = 0.10,
    this.baseOpacity = 0.01,
  });

  List<BlurConfig> get _defaultLayerConfigs => const [
        // Rect A - Largest of the 3, closest to base
        BlurConfig(
          layerBlur: 20,
          backgroundBlur: 10,
          opacity: 0.03,
          padding: EdgeInsets.all(0),
        ),
        // Rect B - Middle
        BlurConfig(
          layerBlur: 15,
          backgroundBlur: 5,
          opacity: 0.04,
          padding: EdgeInsets.all(8),
        ),
        // Rect C - Smallest, topmost
        BlurConfig(
          layerBlur: 10,
          backgroundBlur: 1,
          opacity: 0.05,
          padding: EdgeInsets.all(16),
        ),
      ];

  List<InnerShadowConfig> get _defaultHighlightShadows => [
        // First inner shadow
        InnerShadowConfig(
          offset: const Offset(3, -2),
          blurRadius: 7,
          spreadRadius: 0,
          color: Colors.white.withOpacity(0.50),
        ),
        // Second inner shadow
        InnerShadowConfig(
          offset: const Offset(-6, 6),
          blurRadius: 17,
          spreadRadius: 0,
          color: Colors.white.withOpacity(0.80),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final configs = layerConfigs ?? _defaultLayerConfigs;
    final shadows = highlightShadows ?? _defaultHighlightShadows;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = width ?? constraints.maxWidth;
        final effectiveHeight = height ?? constraints.maxHeight;
        final borderRadius = effectiveHeight / 2;

        return SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ========================================
              // STEP 5: Bottom soft shadow layer (lowest)
              // ========================================
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: bottomShadowBlur,
                    sigmaY: bottomShadowBlur,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: Colors.black.withOpacity(bottomShadowOpacity),
                    ),
                  ),
                ),
              ),

              // ========================================
              // STEP 1: Base blurred rectangle
              // ========================================
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: baseBackgroundBlur,
                      sigmaY: baseBackgroundBlur,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        color: Colors.white.withOpacity(baseOpacity),
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================
              // STEPS 2 & 3: 3 layered blurred rectangles
              // ========================================
              ...configs.map((config) => _buildBlurredLayer(
                    config,
                    borderRadius,
                  )),

              // ========================================
              // STEP 4: Top highlight with inner shadows
              // ========================================
              Positioned.fill(
                child: CustomPaint(
                  painter: InnerShadowPainter(
                    shadows: shadows,
                    borderRadius: borderRadius,
                    fillColor: Colors.white.withOpacity(highlightOpacity),
                  ),
                ),
              ),

              // ========================================
              // Child content
              // ========================================
              if (child != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: child!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlurredLayer(BlurConfig config, double borderRadius) {
    // Adjust border radius for padding
    final adjustedRadius = borderRadius - config.padding.top;

    return Positioned.fill(
      child: Padding(
        padding: config.padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(adjustedRadius.clamp(0, double.infinity)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: config.backgroundBlur,
              sigmaY: config.backgroundBlur,
            ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: config.layerBlur,
                sigmaY: config.layerBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(adjustedRadius.clamp(0, double.infinity)),
                  color: Colors.white.withOpacity(config.opacity),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A variant of LiquidGlassPill that adapts to its content
class LiquidGlassPillAdaptive extends StatelessWidget {
  final Widget child;
  final EdgeInsets contentPadding;
  final double? minWidth;
  final double? minHeight;
  final double baseBackgroundBlur;
  final double bottomShadowBlur;
  final double bottomShadowOpacity;
  final double highlightOpacity;
  final double baseOpacity;

  const LiquidGlassPillAdaptive({
    super.key,
    required this.child,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    this.minWidth,
    this.minHeight,
    this.baseBackgroundBlur = 50,
    this.bottomShadowBlur = 74,
    this.bottomShadowOpacity = 0.25,
    this.highlightOpacity = 0.10,
    this.baseOpacity = 0.01,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth ?? 0,
            minHeight: minHeight ?? 0,
          ),
          child: LiquidGlassPill(
            baseBackgroundBlur: baseBackgroundBlur,
            bottomShadowBlur: bottomShadowBlur,
            bottomShadowOpacity: bottomShadowOpacity,
            highlightOpacity: highlightOpacity,
            baseOpacity: baseOpacity,
            child: Padding(
              padding: contentPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

