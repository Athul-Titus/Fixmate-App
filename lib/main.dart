import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_mesh_bg.dart';
import 'screens/home_screen.dart';
import 'screens/diagnose_screen.dart';
import 'screens/search_screen.dart';
import 'screens/services_screen.dart';
import 'screens/account_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const FixMateApp(),
    ),
  );
}

class FixMateApp extends StatelessWidget {
  const FixMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixMate',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainTabNavigator(),
    );
  }
}

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({super.key});

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onGetStarted: () => setState(() => _currentIndex = 1)),
      const DiagnoseScreen(),
      const SearchScreen(),
      const ServicesScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBody: true,
      body: AnimatedMeshBg(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _icons = [
    Icons.home_rounded,
    Icons.build_rounded,
    Icons.manage_search_rounded,
    Icons.home_repair_service_rounded,
    Icons.person_rounded,
  ];
  static const _labels = ['Home', 'Diagnose', 'Search', 'Services', 'Account'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE60B0B12),
        border: const Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              final selected = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: selected
                      ? BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: selected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(_icons[i],
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                          size: 22),
                      ),
                      const SizedBox(height: 3),
                      Text(_labels[i],
                        style: TextStyle(
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Custom slide-up + fade page route.
Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, __) => page,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      final slideAnim = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeIn);
      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(position: slideAnim, child: child),
      );
    },
  );
}
