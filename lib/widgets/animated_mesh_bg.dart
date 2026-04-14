import 'package:flutter/material.dart';

/// Animated mesh gradient background (Apple WWDC-style glowing orbs).
/// Always renders a dark base color first so the UI is readable on all platforms.
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

    _c1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _c2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _c3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
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
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Solid dark base — always visible on all platforms ──────────
            Container(color: const Color(0xFF07060F)),

            // ── Orb 1 — violet ─────────────────────────────────────────────
            Align(
              alignment: _a1.value,
              child: _Orb(color: const Color(0xFF7C6FF7), sizeFraction: 0.7),
            ),
            // ── Orb 2 — cyan ───────────────────────────────────────────────
            Align(
              alignment: _a2.value,
              child: _Orb(color: const Color(0xFF3BC9E1), sizeFraction: 0.5),
            ),
            // ── Orb 3 — pink ───────────────────────────────────────────────
            Align(
              alignment: _a3.value,
              child: _Orb(color: const Color(0xFFEC4899), sizeFraction: 0.45),
            ),

            // ── Content ────────────────────────────────────────────────────
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  final double sizeFraction;

  const _Orb({required this.color, required this.sizeFraction});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orbSize = (size.width + size.height) * sizeFraction * 0.6;
    return Container(
      width: orbSize,
      height: orbSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.30),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
