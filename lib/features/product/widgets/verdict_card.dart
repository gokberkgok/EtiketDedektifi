import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ring_progress.dart';
import '../../../models/product.dart';
import '../../../services/product_score.dart';
import 'product_visuals.dart';

class VerdictCard extends StatelessWidget {
  const VerdictCard({super.key, required this.product, required this.score});

  final Product product;
  final ProductScore score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final tint = score.verdict.color(colors);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.heroStart, colors.heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.heroEnd.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductThumb(imageUrl: product.imageUrl, size: 64),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleMedium?.copyWith(
                        color: colors.heroForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (product.brand.isNotEmpty) product.brand,
                        if (product.quantity.isNotEmpty) product.quantity,
                        product.code,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.bodySmall?.copyWith(
                        color: colors.heroMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.heroForeground.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                RingProgress(
                  value: (score.value ?? 0) / 100,
                  color: tint,
                  trackColor: colors.heroForeground.withValues(alpha: 0.12),
                  size: 64,
                  strokeWidth: 7,
                  child: Text(
                    score.value?.toString() ?? '?',
                    style: textStyles.titleLarge?.copyWith(
                      color: colors.heroForeground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: tint,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              score.verdict.icon,
                              size: 14,
                              color: colors.onStatus,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              score.verdict.title,
                              style: textStyles.titleMedium?.copyWith(
                                color: colors.heroForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score.verdict.message,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.heroMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
