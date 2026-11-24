import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';
import 'wheel_motif.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final artSize = compact ? 84.0 : 112.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: compact ? AppSpacing.md : AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: artSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WheelMotif(
                  size: artSize,
                  color: colors.textMuted.withValues(alpha: 0.22),
                  strokeWidth: 1.2,
                ),
                Container(
                  width: artSize * 0.5,
                  height: artSize * 0.5,
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.accentSoft, width: 4),
                  ),
                  child: Icon(icon, color: colors.accent, size: artSize * 0.24),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: textStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            message,
            style: textStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 18),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                textStyle: textStyles.labelLarge,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
