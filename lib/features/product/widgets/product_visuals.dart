import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/additive.dart';
import '../../../models/product.dart';
import '../../../services/product_score.dart';

extension VerdictStyle on Verdict {
  Color color(AppColors colors) => switch (this) {
    Verdict.great => colors.positive,
    Verdict.moderate => colors.caution,
    Verdict.limit => colors.negative,
    Verdict.unknown => colors.textMuted,
  };

  IconData get icon => switch (this) {
    Verdict.great => Icons.verified_rounded,
    Verdict.moderate => Icons.balance_rounded,
    Verdict.limit => Icons.do_not_disturb_on_rounded,
    Verdict.unknown => Icons.help_outline_rounded,
  };
}

extension NutrientLevelStyle on NutrientLevel {
  Color color(AppColors colors) => switch (this) {
    NutrientLevel.low => colors.positive,
    NutrientLevel.moderate => colors.caution,
    NutrientLevel.high => colors.negative,
  };
}

extension AdditiveRiskStyle on AdditiveRisk {
  Color color(AppColors colors) => switch (this) {
    AdditiveRisk.high => colors.negative,
    AdditiveRisk.moderate => colors.caution,
    AdditiveRisk.low => colors.positive,
    AdditiveRisk.unknown => colors.textMuted,
  };
}

Color nutriScoreColor(String grade, AppColors colors) => switch (grade) {
  'a' || 'b' => colors.positive,
  'c' => colors.caution,
  _ => colors.negative,
};

Color novaColor(int group, AppColors colors) => switch (group) {
  1 || 2 => colors.positive,
  3 => colors.caution,
  _ => colors.negative,
};

class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.imageUrl, this.size = 48});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Icon(
      Icons.inventory_2_rounded,
      color: colors.textMuted,
      size: size * 0.45,
    );
    final url = imageUrl;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: url == null
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.cover,
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              errorBuilder: (_, _, _) => placeholder,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
            ),
    );
  }
}

class ScorePill extends StatelessWidget {
  const ScorePill({super.key, required this.score});

  final ProductScore score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = score.verdict.color(colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(score.verdict.icon, size: 14, color: tint),
          const SizedBox(width: 4),
          Text(
            score.value?.toString() ?? '—',
            style: context.textStyles.labelLarge?.copyWith(
              color: tint,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.score,
    required this.onTap,
    this.caption,
    this.trailing,
  });

  final Product product;
  final ProductScore score;
  final VoidCallback onTap;
  final String? caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final details = [
      if (product.brand.isNotEmpty) product.brand,
      if (product.quantity.isNotEmpty) product.quantity,
      ?caption,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md - 2,
          vertical: AppSpacing.sm - 2,
        ),
        child: Row(
          children: [
            ProductThumb(imageUrl: product.imageUrl, size: 46),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName,
                    style: textStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details.isEmpty ? product.code : details,
                    style: textStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing ?? ScorePill(score: score),
          ],
        ),
      ),
    );
  }
}
