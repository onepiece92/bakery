import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primaryRed = Color(0xFFEC4913);
  static const Color caramel = Color(0xFFEA6C3A);
  static const Color golden = Color(0xFFF08050);
  static const Color accent = Color(0xFFC23D0E);
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color warmWhite = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF221510);
  static const Color beige = Color(0xFFF3F4F6);
  static const Color lightGold = Color(0xFFE5E7EB);
  static const Color roseDust = Color(0xFFD1D5DB);
  static const Color textLight = Color(0xFF6B7280);
  static const Color sage = Color(0xFF9CA3AF);
  static const Color text = Color(0xFF181311);
  static const Color white = Color(0xFFFFFFFF);
  static const Color terracotta = Color(0xFFB84313);
  static const Color shadow = Color(0x1A000000);
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, Color(0xFFF08050)],
  );

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, beige, lightGold],
    stops: [0.0, 0.5, 1.0],
  );

  static const Gradient productImageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), backgroundDark],
  );
}