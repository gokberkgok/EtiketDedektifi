import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.hint, this.trailing});

  final String label;
  final String? hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm - 2),
      child: Row(
        children: [
          Text(label, style: textStyles.labelLarge),
          if (hint != null) ...[
            const SizedBox(width: 6),
            Text(hint!, style: textStyles.labelSmall),
          ],
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
