import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimens.dart';
import 'app_colors.dart';
import 'app_typography.dart';

enum AppThemeType {
  premiumDark(label: 'Premium Dark', description: 'Koyu ve odaklı'),
  minimalLight(label: 'Minimal Light', description: 'Ferah ve sade');

  const AppThemeType({required this.label, required this.description});

  final String label;
  final String description;

  AppThemeType get opposite => this == premiumDark ? minimalLight : premiumDark;

  AppColors get palette =>
      this == premiumDark ? AppColors.premiumDark : AppColors.minimalLight;

  ThemeMode get themeMode =>
      this == premiumDark ? ThemeMode.dark : ThemeMode.light;

  static AppThemeType? fromName(String? name) {
    for (final type in values) {
      if (type.name == name) return type;
    }
    return null;
  }
}

abstract final class AppTheme {
  static final ThemeData dark = _build(AppColors.premiumDark, Brightness.dark);
  static final ThemeData light = _build(
    AppColors.minimalLight,
    Brightness.light,
  );

  static SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final textTheme = AppTypography.build(colors);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.accent,
        onSecondary: colors.onAccent,
        error: colors.negative,
        onError: colors.onStatus,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        surfaceContainerLowest: colors.background,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surface,
        surfaceContainerHigh: colors.surface,
        surfaceContainerHighest: colors.surfaceAlt,
        outline: colors.border,
        outlineVariant: colors.border,
        shadow: colors.overlayShadow,
      ),
      textTheme: textTheme,
      extensions: [colors],
      splashFactory: InkRipple.splashFactory,
      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent,
        selectionColor: colors.accent.withValues(alpha: 0.3),
        selectionHandleColor: colors.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        prefixIconColor: colors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colors.accent, width: 1.4),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colors.negative, width: 1.2),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colors.negative, width: 1.4),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.negative),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.snackBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.snackForeground,
        ),
        actionTextColor: colors.accent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: colors.surfaceAlt,
        headerForegroundColor: colors.textPrimary,
        dividerColor: colors.border,
        todayBorder: BorderSide(color: colors.accent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surface,
        dialBackgroundColor: colors.surfaceAlt,
        hourMinuteColor: colors.surfaceAlt,
        dayPeriodColor: colors.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accent),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
