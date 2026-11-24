import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static TextTheme build(AppColors colors) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        color: colors.textPrimary,
        fontFeatures: tabularFigures,
      ),
      headlineSmall: TextStyle(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: colors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14.5,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15.5,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 13.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: colors.textMuted,
      ),
    );
  }
}
