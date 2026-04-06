import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0B3C5D);
  static const Color primaryLight = Color(0xFF134B73);
  static const Color primaryDark = Color(0xFF072A42);

  // Accent
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentLight = Color(0xFFE8CC6E);

  // Status
  static const Color hot = Color(0xFFE74C3C);
  static const Color hotLight = Color(0xFFFF6B6B);
  static const Color warm = Color(0xFFF39C12);
  static const Color warmLight = Color(0xFFFFC048);
  static const Color cold = Color(0xFF95A5A6);
  static const Color coldLight = Color(0xFFB0BEC5);

  // Semantic
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF6DD5A0);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F2F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMid = Color(0xFF5A5A7A);
  static const Color textLight = Color(0xFF9A9ABF);
  static const Color border = Color(0xFFE8EAF0);
  static const Color divider = Color(0xFFF0F0F5);
  static const Color inputBg = Color(0xFFF0F2F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient hotGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [hot, hotLight],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warm, warmLight],
  );

  static LinearGradient avatarGradient(String status) {
    switch (status) {
      case 'hot':
        return hotGradient;
      case 'warm':
        return warmGradient;
      default:
        return const LinearGradient(
          colors: [cold, coldLight],
        );
    }
  }
}
