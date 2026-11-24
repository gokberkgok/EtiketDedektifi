import 'package:flutter/foundation.dart';

import '../models/additive.dart';
import '../models/product.dart';
import 'additive_catalog.dart';

enum Verdict {
  great(
    title: 'Harika seçim',
    message: 'Günlük kullanım için sağlam bir tercih.',
  ),
  moderate(
    title: 'Ölçülü tüket',
    message: 'Ara sıra olur, porsiyona dikkat et.',
  ),
  limit(
    title: 'Sınırlamak daha iyi',
    message: 'Daha sağlıklı bir alternatife bak.',
  ),
  unknown(
    title: 'Yetersiz veri',
    message: 'Bu ürünün henüz besin derecelendirmesi yok.',
  );

  const Verdict({required this.title, required this.message});

  final String title;
  final String message;
}

enum FactorTone { good, neutral, bad }

@immutable
class ScoreFactor {
  const ScoreFactor({
    required this.label,
    required this.impact,
    required this.tone,
  });

  final String label;
  final int impact;
  final FactorTone tone;
}

@immutable
class ProductScore {
  const ProductScore({
    required this.value,
    required this.verdict,
    required this.factors,
  });

  final int? value;
  final Verdict verdict;
  final List<ScoreFactor> factors;
}

abstract final class ProductScorer {
  static const int _maxAdditivePenalty = 40;
  static const Map<String, int> _nutriScorePenalty = {
    'a': 0,
    'b': 10,
    'c': 25,
    'd': 40,
    'e': 55,
  };
  static const Map<int, int> _novaPenalty = {1: 0, 2: 5, 3: 10, 4: 20};
  static const Map<int, String> _novaLabels = {
    1: 'İşlenmemiş veya az işlenmiş',
    2: 'İşlenmiş mutfak malzemesi',
    3: 'İşlenmiş gıda',
    4: 'Ultra işlenmiş gıda',
  };
  static const int _highNutrientPenalty = 6;

  static String novaLabel(int group) => _novaLabels[group] ?? 'NOVA $group';

  static ProductScore evaluate(Product product, AdditiveCatalog catalog) {
    final additives = catalog.resolveAll(product.additiveCodes);
    if (!product.hasNutritionData) {
      return ProductScore(
        value: null,
        verdict: Verdict.unknown,
        factors: _additiveFactors(additives),
      );
    }

    final factors = <ScoreFactor>[];
    final grade = product.nutriScore;
    if (grade != null) {
      final penalty = _nutriScorePenalty[grade] ?? 0;
      factors.add(
        ScoreFactor(
          label: 'Nutri-Score ${grade.toUpperCase()}',
          impact: -penalty,
          tone: _toneFor(penalty, goodBelow: 11, badFrom: 40),
        ),
      );
    } else {
      for (final entry in product.nutrientLevels.entries) {
        if (entry.value != NutrientLevel.high) continue;
        factors.add(
          ScoreFactor(
            label: '${entry.key.label} yüksek',
            impact: -_highNutrientPenalty,
            tone: FactorTone.bad,
          ),
        );
      }
    }

    final nova = product.novaGroup;
    if (nova != null) {
      final penalty = _novaPenalty[nova] ?? 0;
      factors.add(
        ScoreFactor(
          label: novaLabel(nova),
          impact: -penalty,
          tone: _toneFor(penalty, goodBelow: 6, badFrom: 20),
        ),
      );
    }

    factors.addAll(_additiveFactors(additives));

    final total = factors.fold<int>(100, (sum, factor) => sum + factor.impact);
    final value = total.clamp(0, 100);
    return ProductScore(
      value: value,
      verdict: value >= 70
          ? Verdict.great
          : value >= 40
          ? Verdict.moderate
          : Verdict.limit,
      factors: factors,
    );
  }

  static List<ScoreFactor> _additiveFactors(List<Additive> additives) {
    if (additives.isEmpty) {
      return const [
        ScoreFactor(
          label: 'Katkı maddesi yok',
          impact: 0,
          tone: FactorTone.good,
        ),
      ];
    }
    final flagged = additives
        .where((additive) => additive.risk.weight > 0)
        .toList();
    final penalty = flagged
        .fold<int>(0, (sum, additive) => sum + additive.risk.weight)
        .clamp(0, _maxAdditivePenalty);
    return [
      ScoreFactor(
        label: flagged.isEmpty
            ? '${additives.length} katkı, hiçbiri işaretli değil'
            : '${flagged.length} riskli katkı maddesi',
        impact: -penalty,
        tone: flagged.isEmpty ? FactorTone.neutral : FactorTone.bad,
      ),
    ];
  }

  static FactorTone _toneFor(
    int penalty, {
    required int goodBelow,
    required int badFrom,
  }) {
    if (penalty < goodBelow) return FactorTone.good;
    if (penalty >= badFrom) return FactorTone.bad;
    return FactorTone.neutral;
  }
}
