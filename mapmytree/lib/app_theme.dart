import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFF8BC34A);
  static const Color accentDark = Color(0xFF558B2F);
  static const Color background = Color(0xFFF5F9F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF0F7EC);
  static const Color textPrimary = Color(0xFF1A2E1A);
  static const Color textSecondary = Color(0xFF5C7A5C);
  static const Color textLight = Color(0xFF8FA68F);
  static const Color divider = Color(0xFFDCEBDC);
  static const Color orange = Color(0xFFFF7043);
  static const Color teal = Color(0xFF26A69A);
  static const Color yellow = Color(0xFFFFD54F);

  // Missing colors required by PlantTreeScreen & AuthScreen
  static const Color offWhite = Color(0xFFF9F9F9);
  static const Color primaryGreen = primary;
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF616161);
  static const Color charcoal = Color(0xFF333333);
  static const Color paleGreen = Color(0xFFE8F5E9);
  static const Color accentGreen = accent;
  static const Color white = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}
