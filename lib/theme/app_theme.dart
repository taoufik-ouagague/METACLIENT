import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors requested by user
  static const Color primary = Color(0xFF2193B0);
  static const Color primaryIcons = Color(0xFF22B7CE);
  static const Color accentCyan = Color(0xFF6DD5ED);
  
  // Background Colors (Deep Glassmorphic Canvas)
  static const Color bgDark = Color(0xFF09111E);
  static const Color bgDarkAlt = Color(0xFF0F1B2D);
  static const Color bgSurface = Color(0xFF132238);

  // Glassmorphic Surface & Border Colors
  static Color glassBg = Colors.white.withOpacity(0.07);
  static Color glassBgHover = Colors.white.withOpacity(0.12);
  static Color glassBorder = Colors.white.withOpacity(0.18);
  static Color glassBorderActive = const Color(0xFF22B7CE).withOpacity(0.6);

  // Status Colors
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient iconGradient = LinearGradient(
    colors: [Color(0xFF22B7CE), Color(0xFF6DD5ED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0AFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF070D18), Color(0xFF0C1728), Color(0xFF0A1F36)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryIcons,
        surface: bgSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: const Color(0xFFCBD5E1),
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.poppins(
          color: const Color(0xFF94A3B8),
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: primaryIcons),
      ),
    );
  }
}
