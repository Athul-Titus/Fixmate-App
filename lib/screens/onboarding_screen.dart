import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;
  late AnimationController _slideCtrl;
  late AnimationController _dotCtrl;

  final _pages = const [
    _OnboardPage(
      gradient: AppTheme.primaryGrad,
      icon: Icons.build_circle_rounded,
      title: 'Diagnose Any\nAppliance',
      subtitle:
          'Select your brand, appliance, and issue — get a professional solution in seconds.',
      emoji: '🔧',
    ),
    _OnboardPage(
      gradient: AppTheme.cyanGrad,
      icon: Icons.manage_search_rounded,
      title: 'Smart Search\nAnything',
      subtitle:
          'Search across thousands of appliance fixes — from refrigerators to ACs.',
      emoji: '🔍',
    ),
    _OnboardPage(
      gradient: AppTheme.accentGrad,
      icon: Icons.bookmark_rounded,
      title: 'Save & Track\nSolutions',
      subtitle:
          'Bookmark fixes for quick access. Your diagnosis history is always saved.',
      emoji: '⭐',
    ),
    _OnboardPage(
      gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)]),
      icon: Icons.home_repair_service_rounded,
      title: 'Book Expert\nTechnicians',
      subtitle:
          'Need hands-on help? Book a certified repair technician at your doorstep.',
      emoji: '👨‍🔧',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _slideCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07060F),
      body: Stack(
        children: [
          // animated bg tint matching current page
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 1.2,
                colors: [
                  _pages[_page].gradient.colors.first.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                    child: GestureDetector(
                      onTap: _finish,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        borderRadius: 12,
                        child: const Text('Skip',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                  ),
                ),

                // Dots + next button
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Row(
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 7),
                            width: i == _page ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              gradient: i == _page
                                  ? _pages[_page].gradient
                                  : null,
                              color: i == _page
                                  ? null
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: i == _page
                                  ? [
                                      BoxShadow(
                                          color: _pages[_page]
                                              .gradient
                                              .colors
                                              .first
                                              .withValues(alpha: 0.6),
                                          blurRadius: 8)
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Next / Get Started
                      GlowButton(
                        label: _page == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        colors: _pages[_page].gradient.colors,
                        icon: _page == _pages.length - 1
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatefulWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    final slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon orb
              Tilt3DCard(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: widget.page.gradient,
                    borderRadius: BorderRadius.circular(44),
                    boxShadow: [
                      BoxShadow(
                          color: widget.page.gradient.colors.first
                              .withValues(alpha: 0.55),
                          blurRadius: 40,
                          offset: const Offset(0, 16))
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(widget.page.icon, size: 64, color: Colors.white),
                      Positioned(
                        bottom: 14,
                        right: 14,
                        child: Text(widget.page.emoji,
                            style: const TextStyle(fontSize: 24)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Text(
                widget.page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.page.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String emoji;
  const _OnboardPage({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });
}
