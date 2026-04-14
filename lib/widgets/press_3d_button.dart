import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// A widget that applies a 3D press + tilt effect on tap.
/// Wraps any child (card, button, etc.)
class Press3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double depth;

  const Press3D({
    super.key,
    required this.child,
    this.onTap,
    this.depth = 0.015,
  });

  @override
  State<Press3D> createState() => _Press3DState();
}

class _Press3DState extends State<Press3D> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    HapticFeedback.lightImpact();
    _ctrl.forward();
  }

  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..scale(_scale.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// 3D tilt card — tilts in the direction of the user's touch.
class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final VoidCallback? onTap;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTilt = 0.08,
    this.onTap,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> with SingleTickerProviderStateMixin {
  double _tiltX = 0;
  double _tiltY = 0;
  double _scale = 1.0;

  void _onPanUpdate(DragUpdateDetails d) {
    final size = context.size;
    if (size == null) return;
    setState(() {
      _tiltY = ((d.localPosition.dx / size.width) - 0.5) * 2 * widget.maxTilt;
      _tiltX = -((d.localPosition.dy / size.height) - 0.5) * 2 * widget.maxTilt;
    });
  }

  void _onPanEnd(_) {
    setState(() { _tiltX = 0; _tiltY = 0; _scale = 1.0; });
  }

  void _onPanStart(_) {
    HapticFeedback.selectionClick();
    setState(() => _scale = 1.02);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltX)
            ..rotateY(_tiltY)
            ..scale(_scale),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A full-width glowing gradient button with press animation.
class GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final List<Color>? colors;
  final IconData? icon;
  final bool isLoading;

  const GlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.colors,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final gradColors = widget.colors ?? [AppTheme.primary, AppTheme.primaryGlow];
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.mediumImpact(); _ctrl.forward(); },
      onTapUp: (_) { _ctrl.reverse(); widget.onPressed?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradColors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradColors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
