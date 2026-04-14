import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String _error = '';

  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() { _entryCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) { setState(() => _error = 'Please fill in all fields'); return; }

    setState(() { _isLoading = true; _error = ''; });
    try {
      await context.read<AuthProvider>().login(email, pass);
      if (mounted) widget.onLoginSuccess();
    } on Exception catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => FadeTransition(
              opacity: _entryCtrl,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Logo + title
                Center(child: Column(children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGrad,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.5),
                        blurRadius: 30, offset: const Offset(0, 10),
                      )],
                    ),
                    child: const Icon(Icons.build_circle_rounded, size: 46, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text('FixMate', style: TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.text,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: AppTheme.primary.withValues(alpha: 0.6), blurRadius: 20)],
                  )),
                  const SizedBox(height: 4),
                  const Text('Welcome back', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ])),

                const SizedBox(height: 36),

                // Glass form card
                GlassCardShimmer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Error banner
                      if (_error.isNotEmpty) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: 12,
                          tintColor: AppTheme.error,
                          opacity: 0.12,
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error, style: const TextStyle(
                              color: AppTheme.error, fontSize: 13))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: AppTheme.text),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                        style: const TextStyle(color: AppTheme.text),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppTheme.textSecondary),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlowButton(label: 'Sign In', icon: Icons.login_rounded,
                        isLoading: _isLoading, onPressed: _handleLogin),
                      const SizedBox(height: 16),
                      Center(child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (_) => SignupScreen(onSignupSuccess: widget.onLoginSuccess))),
                        child: RichText(text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          children: [TextSpan(text: 'Sign Up',
                            style: TextStyle(color: AppTheme.primaryGlow, fontWeight: FontWeight.bold))],
                        )),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
