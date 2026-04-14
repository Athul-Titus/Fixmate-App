import 'package:flutter/material.dart';

class AppTheme {
  // ─── Color Palette (visionOS / iOS dark) ─────────────────────────────────
  static const Color bg         = Color(0xFF0B0B12);   // near-black
  static const Color surface    = Color(0xFF14141E);   // card bg
  static const Color glass      = Color(0x1AFFFFFF);   // 10% white
  static const Color glassStroke= Color(0x2DFFFFFF);   // 18% white
  static const Color primary    = Color(0xFF7C6FF7);   // violet
  static const Color primaryGlow= Color(0xFF9D85FF);   // lighter violet glow
  static const Color accent     = Color(0xFF3BC9E1);   // cyan
  static const Color accentPink = Color(0xFFF472B6);   // pink
  static const Color text       = Color(0xFFEEEEF8);   // near-white
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color border     = Color(0xFF252535);
  static const Color error      = Color(0xFFFF6B6B);
  static const Color success    = Color(0xFF34D399);

  // ─── Gradient presets ────────────────────────────────────────────────────
  static const LinearGradient meshGrad1 = LinearGradient(
    colors: [Color(0xFF7C6FF7), Color(0xFF3BC9E1)],
  );

  static const LinearGradient primaryGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C6FF7), Color(0xFF5B4FD4)],
  );

  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
  );

  static const LinearGradient cyanGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF3BC9E1)],
  );

  // ─── ThemeData ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x14FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x2DFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x2DFFFFFF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        prefixIconColor: primaryGlow,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xE6100B0B12),
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
