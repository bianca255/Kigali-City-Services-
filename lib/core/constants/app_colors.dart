import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF00897B);
  static const Color accent = Color(0xFFFFA726);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x1A000000);

  // Category colours
  static const Map<String, Color> categoryColors = {
    'Hospital': Color(0xFFE53935),
    'Police Station': Color(0xFF1565C0),
    'Library': Color(0xFF6A1B9A),
    'Restaurant': Color(0xFFEF6C00),
    'Café': Color(0xFF5D4037),
    'Park': Color(0xFF2E7D32),
    'Tourist Attraction': Color(0xFFF9A825),
    'Utility Office': Color(0xFF00838F),
  };

  static Color categoryColor(String category) =>
      categoryColors[category] ?? primary;
}
