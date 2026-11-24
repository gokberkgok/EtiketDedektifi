import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.foregroundColor,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = color ?? colors.accent;
    final foreground = foregroundColor ?? colors.onAccent;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withValues(alpha: 0.6),
          disabledForegroundColor: foreground,
          textStyle: context.textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.fast,
          child: isLoading
              ? SizedBox.square(
                  key: const ValueKey('loading'),
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: foreground,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
