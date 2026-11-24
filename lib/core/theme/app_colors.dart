import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.cardBorder,
    required this.cardShadow,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.positive,
    required this.caution,
    required this.negative,
    required this.onStatus,
    required this.heroStart,
    required this.heroEnd,
    required this.heroForeground,
    required this.navBackground,
    required this.overlayShadow,
    required this.snackBackground,
    required this.snackForeground,
  });

  static const AppColors premiumDark = AppColors(
    background: Color(0xFF10131C),
    surface: Color(0xFF1B2030),
    surfaceAlt: Color(0xFF252C3D),
    border: Color(0xFF2B3346),
    cardBorder: Color(0x0FFFFFFF),
    cardShadow: Color(0x00000000),
    accent: Color(0xFFAEB9FF),
    onAccent: Color(0xFF111633),
    textPrimary: Color(0xFFF2F4F8),
    textSecondary: Color(0xFF9CA5B8),
    textMuted: Color(0xFF677187),
    positive: Color(0xFF5ED69B),
    caution: Color(0xFFFFC857),
    negative: Color(0xFFFF7B6B),
    onStatus: Color(0xFF10131C),
    heroStart: Color(0xFFB9C3FF),
    heroEnd: Color(0xFF8E9DFB),
    heroForeground: Color(0xFF111633),
    navBackground: Color(0xFF1E2435),
    overlayShadow: Color(0x73000000),
    snackBackground: Color(0xFF2A3245),
    snackForeground: Color(0xFFF2F4F8),
  );

  static const AppColors minimalLight = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F3F8),
    border: Color(0xFFE9EDF2),
    cardBorder: Color(0xFFE9EDF2),
    cardShadow: Color(0x0D1B2A4A),
    accent: Color(0xFF536DFE),
    onAccent: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF17202D),
    textSecondary: Color(0xFF667085),
    textMuted: Color(0xFF98A2B3),
    positive: Color(0xFF12A66A),
    caution: Color(0xFFE09A12),
    negative: Color(0xFFEF5B4C),
    onStatus: Color(0xFFFFFFFF),
    heroStart: Color(0xFF5B74FF),
    heroEnd: Color(0xFF4259EC),
    heroForeground: Color(0xFFFFFFFF),
    navBackground: Color(0xFFFFFFFF),
    overlayShadow: Color(0x1F1B2A4A),
    snackBackground: Color(0xFF17202D),
    snackForeground: Color(0xFFFFFFFF),
  );

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color cardBorder;
  final Color cardShadow;
  final Color accent;
  final Color onAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color positive;
  final Color caution;
  final Color negative;
  final Color onStatus;
  final Color heroStart;
  final Color heroEnd;
  final Color heroForeground;
  final Color navBackground;
  final Color overlayShadow;
  final Color snackBackground;
  final Color snackForeground;

  Color get accentSoft => accent.withValues(alpha: 0.14);

  Color get heroMuted => heroForeground.withValues(alpha: 0.62);

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? cardBorder,
    Color? cardShadow,
    Color? accent,
    Color? onAccent,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? positive,
    Color? caution,
    Color? negative,
    Color? onStatus,
    Color? heroStart,
    Color? heroEnd,
    Color? heroForeground,
    Color? navBackground,
    Color? overlayShadow,
    Color? snackBackground,
    Color? snackForeground,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      positive: positive ?? this.positive,
      caution: caution ?? this.caution,
      negative: negative ?? this.negative,
      onStatus: onStatus ?? this.onStatus,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      heroForeground: heroForeground ?? this.heroForeground,
      navBackground: navBackground ?? this.navBackground,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      snackBackground: snackBackground ?? this.snackBackground,
      snackForeground: snackForeground ?? this.snackForeground,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      border: mix(border, other.border),
      cardBorder: mix(cardBorder, other.cardBorder),
      cardShadow: mix(cardShadow, other.cardShadow),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      positive: mix(positive, other.positive),
      caution: mix(caution, other.caution),
      negative: mix(negative, other.negative),
      onStatus: mix(onStatus, other.onStatus),
      heroStart: mix(heroStart, other.heroStart),
      heroEnd: mix(heroEnd, other.heroEnd),
      heroForeground: mix(heroForeground, other.heroForeground),
      navBackground: mix(navBackground, other.navBackground),
      overlayShadow: mix(overlayShadow, other.overlayShadow),
      snackBackground: mix(snackBackground, other.snackBackground),
      snackForeground: mix(snackForeground, other.snackForeground),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
