import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/nutrition_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/product.dart';
import '../../../services/product_score.dart';

enum _Better { higher, lower }

class _Metric {
  const _Metric({
    required this.label,
    required this.first,
    required this.second,
    required this.better,
    required this.format,
  });

  final String label;
  final num? first;
  final num? second;
  final _Better better;
  final String Function(num value) format;

  int? get winner {
    final a = first;
    final b = second;
    if (a == null || b == null || a == b) return null;
    final firstWins = better == _Better.higher ? a > b : a < b;
    return firstWins ? 0 : 1;
  }
}

class ComparisonTable extends StatelessWidget {
  const ComparisonTable({
    super.key,
    required this.first,
    required this.second,
    required this.firstScore,
    required this.secondScore,
    required this.firstFlagged,
    required this.secondFlagged,
  });

  final Product first;
  final Product second;
  final ProductScore firstScore;
  final ProductScore secondScore;
  final int firstFlagged;
  final int secondFlagged;

  List<_Metric> get _metrics => [
    _Metric(
      label: 'Dedektif puanı',
      first: firstScore.value,
      second: secondScore.value,
      better: _Better.higher,
      format: (value) => '$value',
    ),
    _Metric(
      label: 'Nutri-Score',
      first: _gradeRank(first.nutriScore),
      second: _gradeRank(second.nutriScore),
      better: _Better.lower,
      format: (value) => 'ABCDE'[value.toInt()],
    ),
    _Metric(
      label: 'İşlenmişlik (NOVA)',
      first: first.novaGroup,
      second: second.novaGroup,
      better: _Better.lower,
      format: (value) => '$value',
    ),
    _Metric(
      label: 'Kalori',
      first: first.energyKcalPer100g,
      second: second.energyKcalPer100g,
      better: _Better.lower,
      format: NutritionFormat.kcal,
    ),
    for (final nutrient in [
      Nutrient.sugars,
      Nutrient.salt,
      Nutrient.saturatedFat,
    ])
      _Metric(
        label: nutrient.label,
        first: first.nutrientsPer100g[nutrient],
        second: second.nutrientsPer100g[nutrient],
        better: _Better.lower,
        format: NutritionFormat.grams,
      ),
    _Metric(
      label: 'Riskli katkılar',
      first: firstFlagged,
      second: secondFlagged,
      better: _Better.lower,
      format: (value) => '$value',
    ),
  ];

  static int? _gradeRank(String? grade) =>
      grade == null ? null : 'abcde'.indexOf(grade);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final metrics = _metrics;
    final firstWins = metrics.where((metric) => metric.winner == 0).length;
    final secondWins = metrics.where((metric) => metric.winner == 1).length;
    final firstLeads = firstWins > secondWins;
    final summary = firstWins == secondWins
        ? 'Başa baş; senin için en önemli kritere bak.'
        : '${firstLeads ? first.displayName : second.displayName}, '
              '${firstWins + secondWins} kriterin '
              '${firstLeads ? firstWins : secondWins} tanesinde önde.';

    return Column(
      children: [
        AppCard(
          color: colors.accentSoft,
          child: Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: colors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(summary, style: textStyles.titleSmall)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    _HeaderCell(text: 'A'),
                    _HeaderCell(text: 'B'),
                  ],
                ),
              ),
              for (final metric in metrics)
                if (metric.first != null || metric.second != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            metric.label,
                            style: textStyles.bodyMedium,
                          ),
                        ),
                        _ValueCell(
                          value: metric.first == null
                              ? '—'
                              : metric.format(metric.first!),
                          isWinner: metric.winner == 0,
                        ),
                        _ValueCell(
                          value: metric.second == null
                              ? '—'
                              : metric.format(metric.second!),
                          isWinner: metric.winner == 1,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.textStyles.labelLarge,
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({required this.value, required this.isWinner});

  final String value;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 84,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isWinner
                ? colors.positive.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            value,
            style: context.textStyles.labelLarge?.copyWith(
              color: isWinner ? colors.positive : colors.textSecondary,
              fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
