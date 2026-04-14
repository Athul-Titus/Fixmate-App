import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return _NotLoggedIn(onLogin: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => LoginScreen(onLoginSuccess: () => Navigator.pop(context)))));
        }
        return _LoggedIn(auth: auth);
      },
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  final VoidCallback onLogin;
  const _NotLoggedIn({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassCardShimmer(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGrad,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.45),
                      blurRadius: 24, offset: const Offset(0, 8),
                    )],
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 18),
                const Text('Sign in to FixMate', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.text)),
                const SizedBox(height: 6),
                const Text('Track bookings and sync across devices',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                const SizedBox(height: 24),
                GlowButton(label: 'Login / Sign Up', icon: Icons.login_rounded, onPressed: onLogin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoggedIn extends StatelessWidget {
  final AuthProvider auth;
  const _LoggedIn({required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = auth.user!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              const Text('Account', style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900,
                color: AppTheme.text, letterSpacing: -0.5,
              )),
              const SizedBox(height: 20),

              // Profile card
              Tilt3DCard(
                child: GlassCardShimmer(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      // Avatar with glow ring
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGrad,
                          boxShadow: [BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            blurRadius: 20, spreadRadius: 2,
                          )],
                        ),
                        child: Center(child: Text(
                          (user['name'] as String? ?? 'U').isNotEmpty
                              ? (user['name'] as String).substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name'] ?? 'User', style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text)),
                          const SizedBox(height: 3),
                          Text(user['email'] ?? '', style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.verified_rounded, size: 12, color: AppTheme.success),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
                      )),
                      Press3D(
                        onTap: () async { await auth.logout(); },
                        child: GlassCard(
                          padding: const EdgeInsets.all(10),
                          borderRadius: 12,
                          tintColor: AppTheme.error,
                          opacity: 0.1,
                          child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text('Settings', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.text)),
              const SizedBox(height: 14),

              _AccountMenuItem(
                icon: Icons.history_rounded,
                label: 'My Bookings',
                subtitle: 'View past and upcoming bookings',
                gradient: AppTheme.primaryGrad,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!'), backgroundColor: Color(0xFF1E1E2E))),
              ),
              const SizedBox(height: 10),
              _AccountMenuItem(
                icon: Icons.settings_rounded,
                label: 'App Settings',
                subtitle: 'Preferences and notifications',
                gradient: AppTheme.cyanGrad,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _AccountMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                subtitle: 'FAQs and contact us',
                gradient: AppTheme.accentGrad,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _AccountMenuItem(
                icon: Icons.laptop_mac_rounded,
                label: 'Web Version',
                subtitle: 'fixmate-app-ykux.onrender.com',
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                onTap: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _AccountMenuItem({required this.icon, required this.label, required this.subtitle,
    required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Press3D(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 10, offset: const Offset(0, 3),
                )],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.text)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            )),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
