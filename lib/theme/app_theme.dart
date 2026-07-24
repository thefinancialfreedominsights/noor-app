import 'package:flutter/material.dart';

/// Central place for all colors/typography so the whole app stays consistent.
/// Palette: deep teal (calm, trustworthy) + warm gold accent (light, premium feel)
/// — deliberately avoiding the generic "bright green mosque icon" cliché most
/// prayer apps use, so Noor looks more premium on the Play Store listing.
class AppTheme {
  static const Color primaryTeal = Color(0xFF0E4749);
  static const Color accentGold = Color(0xFFC9A15A);
  static const Color backgroundLight = Color(0xFFF7F5F0);
  static const Color backgroundDark = Color(0xFF0B2426);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.light,
        primary: primaryTeal,
        secondary: accentGold,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: primaryTeal,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: accentGold.withOpacity(0.25),
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        brightness: Brightness.dark,
        primary: accentGold,
        secondary: accentGold,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: accentGold,
        elevation: 0,
        centerTitle: true,
      ),
      fontFamily: 'Roboto',
    );
  }
}
