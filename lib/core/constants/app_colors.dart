import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Secondary Teals
  static const Color deepForestTeal = Color(0xFF124B45);
  static const Color primaryTeal = Color(0xFF176B63);
  static const Color lightTeal = Color(0xFF2C8A7F);
  static const Color tealSurface = Color(0xFFE8F1EA);

  // Backgrounds & Neutrals
  static const Color warmCream = Color(0xFFFAF8F3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF242B2A);
  static const Color secondaryGrey = Color(0xFF78817E);
  static const Color lightGrey = Color(0xFFF0F2F1);
  static const Color borderGrey = Color(0xFFE2E6E4);

  // Accent & Status Colors
  static const Color terracotta = Color(0xFFC76B4A);
  static const Color mutedSaffron = Color(0xFFD8A64A);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color infoBlue = Color(0xFF1976D2);

  // Card & Elevation Shadows
  static BoxShadow softShadow = BoxShadow(
    color: charcoal.withAlpha((0.06 * 255).round()),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: charcoal.withAlpha((0.12 * 255).round()),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
