import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted glass card — wraps any child with BackdropFilter blur.
/// Place this over the animated mesh background for the glass effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final Color? tintColor;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.blur = 24,
    this.opacity = 0.10,
    this.tintColor,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = tintColor ?? Colors.white;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.2)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A glass card with a subtle gradient shimmer on the top edge.
class GlassCardShimmer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  const GlassCardShimmer({super.key, required this.child, this.padding, this.borderRadius = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}
