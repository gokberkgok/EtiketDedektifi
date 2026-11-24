import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

abstract final class AppFeedback {
  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    bool aboveNavigation = true,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: context.colors.positive,
      actionLabel: actionLabel,
      onAction: onAction,
      aboveNavigation: aboveNavigation,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    bool aboveNavigation = true,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      iconColor: context.colors.negative,
      aboveNavigation: aboveNavigation,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required bool aboveNavigation,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = context.colors;
    final bottomMargin = aboveNavigation
        ? AppSpacing.navigationClearance - AppSpacing.lg
        : AppSpacing.md;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            0,
            AppSpacing.screen,
            bottomMargin,
          ),
          duration: const Duration(milliseconds: 2800),
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: colors.snackForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => _ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      icon: icon,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.negative.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.negative, size: 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: textStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      backgroundColor: colors.surfaceAlt,
                      minimumSize: const Size.fromHeight(48),
                      shape: buttonShape,
                    ),
                    child: const Text('Vazgeç'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.negative,
                      foregroundColor: colors.onStatus,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: textStyles.labelLarge,
                      shape: buttonShape,
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
