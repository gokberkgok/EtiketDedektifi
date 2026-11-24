import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.color,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final Color? color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = color ?? colors.accent;
    final iconColor = selected || (color != null && !outlined)
        ? activeColor
        : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? activeColor.withValues(alpha: 0.16)
                  : outlined
                  ? Colors.transparent
                  : colors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected
                    ? activeColor
                    : outlined
                    ? colors.border
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: context.textStyles.labelLarge?.copyWith(
                    color: selected ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
