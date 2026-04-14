import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted glass card — works correctly on both mobile and web.
/// On mobile: BackdropFilter blurs the mesh background behind the card.
/// On web: the dark fill ensures readability even without perfect blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tintColor;
  final bool showBorder;
  final double? opacity; // kept for API compat — affects dark tint strength

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.blur = 18,
    this.tintColor,
    this.showBorder = true,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Dark semi-transparent base so text is always readable
            color: tintColor != null
                ? tintColor!.withValues(alpha: 0.18)
                : const Color(0xFF1E1A30).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                    width: 1.2)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shimmer-style glass card with a subtle dark gradient.
class GlassCardShimmer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  const GlassCardShimmer(
      {super.key,
      required this.child,
      this.padding,
      this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xCC1E1A35), // ~80% dark
                Color(0xAA14101F), // ~67% darker
              ],
            ),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.16), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}
