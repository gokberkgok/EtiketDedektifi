import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

class SegmentOption<T> {
  const SegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.activeColor,
    this.activeForegroundColor,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? activeColor;
  final Color? activeForegroundColor;
}

class SegmentedSwitch<T> extends StatelessWidget {
  const SegmentedSwitch({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.height = 46,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  static const double _inset = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final selectedIndex = math.max(
      0,
      options.indexWhere((option) => option.value == selected),
    );
    final indicatorColor = options[selectedIndex].activeColor ?? colors.surface;
    final alignmentX = options.length == 1
        ? 0.0
        : -1 + 2 * selectedIndex / (options.length - 1);

    return Container(
      height: height,
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / options.length;
          return Stack(
            children: [
              AnimatedAlign(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignmentX, 0),
                child: AnimatedContainer(
                  duration: AppDurations.medium,
                  width: segmentWidth,
                  height: height - _inset * 2,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: [
                      BoxShadow(
                        color: colors.overlayShadow.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: _SegmentLabel(
                        option: option,
                        isSelected: option.value == selected,
                        foreground: option.value == selected
                            ? option.activeForegroundColor ?? colors.textPrimary
                            : colors.textSecondary,
                        textStyle: textStyles.labelLarge,
                        onTap: () {
                          if (option.value == selected) return;
                          HapticFeedback.selectionClick();
                          onChanged(option.value);
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentLabel<T> extends StatelessWidget {
  const _SegmentLabel({
    required this.option,
    required this.isSelected,
    required this.foreground,
    required this.textStyle,
    required this.onTap,
  });

  final SegmentOption<T> option;
  final bool isSelected;
  final Color foreground;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.fast,
            style: (textStyle ?? const TextStyle()).copyWith(color: foreground),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
