import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for Noor's visual identity: a deep emerald/near-black
/// palette with a rich gold accent, an elegant serif for numerals and
/// headings, and a clean sans for body/UI text.
class AppTheme {
  static const Color bgDeep = Color(0xFF071614);
  static const Color surfaceCard = Color(0xFF0F2B27);
  static const Color surfaceCardLight = Color(0xFF163832);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D896);
  static const Color textPrimary = Color(0xFFF5F1E6);
  static const Color textMuted = Color(0xFF9BB0AC);
  static const Color divider = Color(0x1FF5F1E6);

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 56,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.0,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: goldLight,
          letterSpacing: 2.2,
        ),
        bodyLarge: GoogleFonts.manrope(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.manrope(fontSize: 14, color: textMuted),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      );

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldLight,
        surface: surfaceCard,
        onSurface: textPrimary,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bgDeep,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceCard,
        indicatorColor: gold.withOpacity(0.18),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.manrope(fontSize: 11, color: textMuted, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? gold : textMuted);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: bgDeep,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
    return base;
  }

  static ThemeData get light => dark;

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: gold.withOpacity(0.18),
          blurRadius: 40,
          spreadRadius: -4,
        ),
      ];
}
