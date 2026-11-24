import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/nutrition_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/additive.dart';
import '../../../models/product.dart';
import '../../../services/product_score.dart';
import 'product_visuals.dart';

class ScoreFactorsCard extends StatelessWidget {
  const ScoreFactorsCard({super.key, required this.score});

  final ProductScore score;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          for (final factor in score.factors)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    switch (factor.tone) {
                      FactorTone.good => Icons.check_circle_rounded,
                      FactorTone.neutral => Icons.remove_circle_rounded,
                      FactorTone.bad => Icons.error_rounded,
                    },
                    size: 18,
                    color: switch (factor.tone) {
                      FactorTone.good => colors.positive,
                      FactorTone.neutral => colors.caution,
                      FactorTone.bad => colors.negative,
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(factor.label, style: textStyles.bodyMedium),
                  ),
                  Text(
                    factor.impact == 0 ? '0' : '${factor.impact}',
                    style: textStyles.labelLarge?.copyWith(
                      color: factor.impact < 0
                          ? colors.negative
                          : colors.textMuted,
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

class RatingBadgesRow extends StatelessWidget {
  const RatingBadgesRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grade = product.nutriScore;
    final nova = product.novaGroup;

    return Row(
      children: [
        Expanded(
          child: _RatingBadge(
            title: 'Nutri-Score',
            value: grade?.toUpperCase() ?? '—',
            caption: grade == null
                ? 'Derecelendirilmemiş'
                : 'En iyi A, en kötü E',
            color: grade == null
                ? colors.textMuted
                : nutriScoreColor(grade, colors),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _RatingBadge(
            title: 'NOVA',
            value: nova?.toString() ?? '—',
            caption: nova == null
                ? 'Derecelendirilmemiş'
                : ProductScorer.novaLabel(nova),
            color: nova == null ? colors.textMuted : novaColor(nova, colors),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              value,
              style: textStyles.titleLarge?.copyWith(
                color: context.colors.onStatus,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textStyles.labelLarge),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: textStyles.labelSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  const NutritionCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final kcal = product.energyKcalPer100g;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          if (kcal != null)
            _NutritionRow(
              label: 'Enerji',
              value: NutritionFormat.kcal(kcal),
              pill: null,
            ),
          for (final nutrient in Nutrient.values)
            if (product.nutrientsPer100g[nutrient] != null ||
                product.nutrientLevels[nutrient] != null)
              _NutritionRow(
                label: nutrient.label,
                value: product.nutrientsPer100g[nutrient] == null
                    ? '—'
                    : NutritionFormat.grams(
                        product.nutrientsPer100g[nutrient]!,
                      ),
                pill: product.nutrientLevels[nutrient] == null
                    ? null
                    : StatusPill(
                        label: product.nutrientLevels[nutrient]!.label,
                        color: product.nutrientLevels[nutrient]!.color(colors),
                      ),
              ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs, bottom: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('100 g / 100 ml için', style: textStyles.labelSmall),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    required this.pill,
  });

  final String label;
  final String value;
  final Widget? pill;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textStyles.bodyMedium)),
          Text(value, style: textStyles.labelLarge),
          if (pill != null) ...[
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 74,
              child: Align(alignment: Alignment.centerRight, child: pill),
            ),
          ],
        ],
      ),
    );
  }
}

class AdditivesCard extends StatelessWidget {
  const AdditivesCard({super.key, required this.additives});

  final List<Additive> additives;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    if (additives.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.eco_rounded, color: colors.positive),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Bu üründe katkı maddesi listelenmemiş.',
                style: textStyles.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < additives.length; index++) ...[
            if (index > 0) const Divider(indent: 72, endIndent: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md - 2,
                vertical: AppSpacing.sm - 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: additives[index].risk
                          .color(colors)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        additives[index].displayCode,
                        style: textStyles.labelMedium?.copyWith(
                          color: additives[index].risk.color(colors),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          additives[index].name,
                          style: textStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          additives[index].role,
                          style: textStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  StatusPill(
                    label: additives[index].risk.shortLabel,
                    color: additives[index].risk.color(colors),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DietCard extends StatelessWidget {
  const DietCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _DietChip(label: 'Vegan', status: product.vegan),
              _DietChip(label: 'Vejetaryen', status: product.vegetarian),
              _DietChip(label: 'Palm yağı yok', status: product.palmOilFree),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Alerjenler', style: textStyles.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (product.allergens.isEmpty)
            Text('Belirtilmemiş', style: textStyles.bodySmall)
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final allergen in product.allergens)
                  StatusPill(label: allergen, color: colors.negative),
              ],
            ),
        ],
      ),
    );
  }
}

class _DietChip extends StatelessWidget {
  const _DietChip({required this.label, required this.status});

  final String label;
  final DietStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (icon, color) = switch (status) {
      DietStatus.yes => (Icons.check_rounded, colors.positive),
      DietStatus.no => (Icons.close_rounded, colors.negative),
      DietStatus.maybe => (Icons.question_mark_rounded, colors.caution),
      DietStatus.unknown => (Icons.remove_rounded, colors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(label, style: context.textStyles.labelLarge),
        ],
      ),
    );
  }
}

class IngredientsCard extends StatefulWidget {
  const IngredientsCard({super.key, required this.text});

  final String text;

  @override
  State<IngredientsCard> createState() => _IngredientsCardState();
}

class _IngredientsCardState extends State<IngredientsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return AppCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: AppDurations.medium,
            alignment: Alignment.topCenter,
            child: Text(
              widget.text,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: _expanded ? null : 3,
              overflow: _expanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _expanded ? 'Daha az göster' : 'Tümünü göster',
            style: textStyles.labelLarge?.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}
