import 'package:flutter/material.dart';

class PockiColors {
  // Brand Primary Palette
  static const Color primaryPink = Color(0xFFFF4F81);
  static const Color secondaryPurple = Color(0xFF7B4DFF);
  static const Color accentPeach = Color(0xFFFFB347);
  static const Color mintGreen = Color(0xFFB8F2D0);
  static const Color lavender = Color(0xFFE8D9FF);
  static const Color lightBackground = Color(0xFFFFF9FC);
  static const Color cardBackground = Colors.white;
  
  // Text & Dark Elements
  static const Color textDark = Color(0xFF261B35);
  static const Color textMuted = Color(0xFF8C809B);
  static const Color textLight = Color(0xFFB0A5C0);
  
  // Status Colors
  static const Color successGreen = Color(0xFF35C77A);
  static const Color warningOrange = Color(0xFFFFB347);
  static const Color errorRed = Color(0xFFFF5C7A);

  // Soft Pastel Tint Backgrounds
  static const Color pinkTint = Color(0xFFFFEFF4);
  static const Color purpleTint = Color(0xFFF3EDFF);
  static const Color mintTint = Color(0xFFEBFBF2);
  static const Color peachTint = Color(0xFFFFF6EA);

  // Nav Bar
  static const Color navDark = Color(0xFF231535);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4F81), Color(0xFFFFB347)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7B4DFF), Color(0xFFFF4F81)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFF7E95), Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient mascotBannerGradient = LinearGradient(
    colors: [Color(0xFFFFE8F0), Color(0xFFFFF0F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
