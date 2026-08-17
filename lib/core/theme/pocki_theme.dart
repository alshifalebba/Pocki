import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocki_colors.dart';

class PockiTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: PockiColors.lightBackground,
      primaryColor: PockiColors.primaryPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PockiColors.primaryPink,
        primary: PockiColors.primaryPink,
        secondary: PockiColors.secondaryPurple,
        surface: PockiColors.lightBackground,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          color: PockiColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: PockiColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: PockiColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: PockiColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: PockiColors.textDark,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: PockiColors.textMuted,
          fontSize: 13,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEFE8F4), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEFE8F4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PockiColors.primaryPink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: PockiColors.errorRed, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: PockiColors.textLight,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: PockiColors.primaryPink,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
