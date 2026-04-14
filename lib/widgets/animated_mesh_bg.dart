import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated mesh gradient background (Apple WWDC-style glowing orbs).
/// Wrap the full-screen scaffold body with this widget.
class AnimatedMeshBg extends StatefulWidget {
  final Widget child;
  const AnimatedMeshBg({super.key, required this.child});

  @override
  State<AnimatedMeshBg> createState() => _AnimatedMeshBgState();
}

class _AnimatedMeshBgState extends State<AnimatedMeshBg>
    with TickerProviderStateMixin {
  late AnimationController _c1, _c2, _c3;
  late Animation<Alignment> _a1, _a2, _a3;

  @override
  void initState() {
    super.initState();

    _c1 = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _c2 = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _c3 = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);

    _a1 = AlignmentTween(
      begin: const Alignment(-0.8, -0.6),
      end: const Alignment(0.2, 0.4),
    ).animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));

    _a2 = AlignmentTween(
      begin: const Alignment(0.6, -0.8),
      end: const Alignment(-0.4, 0.6),
    ).animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));

    _a3 = AlignmentTween(
      begin: const Alignment(0.0, 0.8),
      end: const Alignment(0.8, -0.4),
    ).animate(CurvedAnimation(parent: _c3, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2, _c3]),
      builder: (context, _) {
        return Stack(
          children: [
            // Base background
            Container(color: const Color(0xFF0B0B12)),

            // Orb 1 — violet
            _Orb(alignment: _a1.value, color: const Color(0xFF7C6FF7), size: 0.8),
            // Orb 2 — cyan
            _Orb(alignment: _a2.value, color: const Color(0xFF3BC9E1), size: 0.6),
            // Orb 3 — pink
            _Orb(alignment: _a3.value, color: const Color(0xFFEC4899), size: 0.5),

            // Content on top
            widget.child,
          ],
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;
  const _Orb({required this.alignment, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final orbSize = screenW * size * 1.2;
    return Align(
      alignment: alignment,
      child: Container(
        width: orbSize,
        height: orbSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle shimmer rotation effect for a single small decorative orb
class FloatingOrb extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  const FloatingOrb({super.key, required this.color, this.size = 120, this.duration = const Duration(seconds: 6)});

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);
    _anim = Tween(begin: -6.0, end: 6.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            widget.color.withValues(alpha: 0.5),
            widget.color.withValues(alpha: 0.0),
          ]),
        ),
      ),
    );
  }
}
