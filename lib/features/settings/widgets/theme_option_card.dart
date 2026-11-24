import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ThemeOptionCard extends StatelessWidget {
  const ThemeOptionCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final AppThemeType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Semantics(
      button: true,
      selected: isSelected,
      label: type.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          padding: const EdgeInsets.all(AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? colors.accent : colors.cardBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThemePreview(palette: type.palette),
              const SizedBox(height: AppSpacing.sm - 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.label,
                            style: textStyles.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            type.description,
                            style: textStyles.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppDurations.fast,
                      child: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        key: ValueKey(isSelected),
                        size: 22,
                        color: isSelected ? colors.accent : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.palette});

  final AppColors palette;

  @override
  Widget build(BuildContext context) {
    Widget line(double width, Color color) => Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );

    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: palette.border.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.heroStart, palette.heroEnd],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    line(28, palette.heroForeground.withValues(alpha: 0.5)),
                    const SizedBox(height: 5),
                    line(54, palette.heroForeground),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: palette.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: palette.positive.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: line(double.infinity, palette.textMuted)),
                    const SizedBox(width: 6),
                    line(16, palette.negative),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
