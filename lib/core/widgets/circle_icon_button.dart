import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = onPressed != null;
    final button = Material(
      color: backgroundColor ?? colors.surface,
      shape: CircleBorder(side: BorderSide(color: colors.cardBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            icon,
            size: iconSize,
            color: (iconColor ?? colors.textPrimary).withValues(
              alpha: isEnabled ? 1 : 0.35,
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}
