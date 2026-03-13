import 'package:flutter/material.dart';

/// Brand colour palette for La Petite Boulangerie.
/// Single source of truth — never hard-code colours elsewhere.
abstract final class AppColors {
  // Brand
  static const Color primaryRed = Color(0xFFEC4913);
  static const Color backgroundLight = Color(0xFFF8F6F6);   // Primary orange-red

  // Backgrounds
  static const Color warmWhite = Color(0xFFF8F6F6);    // Light background
  static const Color darkBrown = Color(0xFF221510);    // Dark background

  // Text
  static const Color text = Color(0xFF181311);         // Primary text

  // Supporting palette (derived to complement the new brand)
  static const Color beige = Color(0xFFF0E6DC);
  static const Color softBrown = Color(0xFF7A5C4E);
  static const Color caramel = Color(0xFFC4855A);
  static const Color golden = Color(0xFFD4935A);
  static const Color accent = Color(0xFFB8700B);
  static const Color lightGold = Color(0xFFEDD9C0);
  static const Color terracotta = Color(0xFFB86840);
  static const Color sage = Color(0xFFA8B89C);
  static const Color roseDust = Color(0xFFC9A9A6);
  static const Color textLight = Color(0xFF7A6560);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000);

  // Gradient shortcuts
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBrown, softBrown],
  );

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [beige, lightGold, golden],
    stops: [0.0, 0.5, 1.0],
  );

  static const Gradient productImageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [beige, lightGold],
  );
}