import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const HomeScreen({super.key, required this.onGetStarted});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroCtrl.forward();
  }

  @override
  void dispose() { _heroCtrl.dispose(); super.dispose(); }

  @override
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(
                position: _heroSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Header ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FixMate', style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.text,
                              letterSpacing: -0.5,
                              shadows: [Shadow(color: AppTheme.primary.withValues(alpha: 0.6), blurRadius: 20)],
                            )),
                            const SizedBox(height: 2),
                            const Text('AI-powered appliance repair', style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                        GlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 14,
                          child: const Icon(Icons.notifications_none_rounded, color: AppTheme.text, size: 22),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Hero 3D tilt card ─────────────────────────
                    Tilt3DCard(
                      onTap: widget.onGetStarted,
                      child: GlassCardShimmer(
                        padding: const EdgeInsets.all(28),
                        borderRadius: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGrad,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: 0.5),
                                      blurRadius: 16, offset: const Offset(0, 4)
                                    )],
                                  ),
                                  child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: 30),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.success.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(width: 6, height: 6,
                                        decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                                      const SizedBox(width: 5),
                                      const Text('Online', style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Diagnose &\nFix Any Appliance', style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900,
                              color: Colors.white, height: 1.2, letterSpacing: -0.3,
                            )),
                            const SizedBox(height: 10),
                            const Text('20+ brands · 1000+ issues · instant solutions', style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13,
                            )),
                            const SizedBox(height: 24),
                            GlowButton(
                              label: 'Start Diagnosing',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: widget.onGetStarted,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Stats strip ───────────────────────────────
                    Row(
                      children: [
                        _StatChip(label: '20+ Brands', icon: Icons.category_rounded, color: AppTheme.primary),
                        const SizedBox(width: 10),
                        _StatChip(label: '1000+ Fixes', icon: Icons.bolt_rounded, color: AppTheme.accent),
                        const SizedBox(width: 10),
                        _StatChip(label: 'Offline', icon: Icons.offline_bolt_rounded, color: AppTheme.accentPink),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Section title ─────────────────────────────
                    const Text('Services', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppTheme.text, letterSpacing: -0.2,
                    )),
                    const SizedBox(height: 16),

                    // ── Service cards ─────────────────────────────
                    _ServiceCard(
                      title: 'Appliance Diagnosis',
                      description: 'Step-by-step repair guidance for 20+ brands.',
                      icon: Icons.settings_suggest_rounded,
                      gradient: AppTheme.primaryGrad,
                      onTap: widget.onGetStarted,
                    ),
                    const SizedBox(height: 12),
                    _ServiceCard(
                      title: 'Technician Booking',
                      description: 'Connect with certified local repair experts.',
                      icon: Icons.handyman_rounded,
                      gradient: AppTheme.accentGrad,
                    ),
                    const SizedBox(height: 12),
                    _ServiceCard(
                      title: 'AC & Electrical',
                      description: 'Cooling, wiring, gas top-up and more.',
                      icon: Icons.ac_unit_rounded,
                      gradient: AppTheme.cyanGrad,
                    ),

                    const SizedBox(height: 24),

                    // ── Web version notice ────────────────────────
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 18,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cyanGrad,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.laptop_mac_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Web Version Available', style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.text)),
                              SizedBox(height: 2),
                              Text('fixmate-app-ykux.onrender.com', style: TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          )),
                          const Icon(Icons.open_in_new_rounded, color: AppTheme.textSecondary, size: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
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

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _StatChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        borderRadius: 14,
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.text)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  const _ServiceCard({required this.title, required this.description, required this.icon, required this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Press3D(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.text)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
              ],
            )),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
