import 'package:flutter/foundation.dart';

enum ProductSource {
  food(label: 'Open Food Facts', host: 'world.openfoodfacts.org'),
  beauty(label: 'Open Beauty Facts', host: 'world.openbeautyfacts.org'),
  products(label: 'Open Products Facts', host: 'world.openproductsfacts.org');

  const ProductSource({required this.label, required this.host});

  final String label;
  final String host;

  static ProductSource fromName(String? name) => values.firstWhere(
    (source) => source.name == name,
    orElse: () => ProductSource.food,
  );
}

enum Nutrient {
  fat(label: 'Yağ', apiKey: 'fat'),
  saturatedFat(label: 'Doymuş yağ', apiKey: 'saturated-fat'),
  sugars(label: 'Şeker', apiKey: 'sugars'),
  salt(label: 'Tuz', apiKey: 'salt');

  const Nutrient({required this.label, required this.apiKey});

  final String label;
  final String apiKey;
}

enum NutrientLevel {
  low('Düşük'),
  moderate('Orta'),
  high('Yüksek');

  const NutrientLevel(this.label);

  final String label;

  static NutrientLevel? fromName(Object? name) {
    for (final level in values) {
      if (level.name == name) return level;
    }
    return null;
  }
}

enum DietStatus {
  yes,
  no,
  maybe,
  unknown;

  static DietStatus fromName(Object? name) => values.firstWhere(
    (status) => status.name == name,
    orElse: () => DietStatus.unknown,
  );
}

@immutable
class Product {
  const Product({
    required this.code,
    required this.name,
    required this.source,
    this.brand = '',
    this.quantity = '',
    this.imageUrl,
    this.nutriScore,
    this.novaGroup,
    this.additiveCodes = const [],
    this.allergens = const [],
    this.vegan = DietStatus.unknown,
    this.vegetarian = DietStatus.unknown,
    this.palmOilFree = DietStatus.unknown,
    this.nutrientLevels = const {},
    this.nutrientsPer100g = const {},
    this.energyKcalPer100g,
    this.ingredientsText = '',
  });

  factory Product.fromApi(Map<String, dynamic> json, ProductSource source) {
    final tags = _stringList(json['ingredients_analysis_tags']);
    final levels = json['nutrient_levels'] is Map
        ? json['nutrient_levels'] as Map
        : const {};
    final nutriments = json['nutriments'] is Map
        ? json['nutriments'] as Map
        : const {};
    final grade = (json['nutriscore_grade'] as String?)?.toLowerCase();

    return Product(
      code: '${json['code'] ?? ''}',
      name: _firstNonEmpty([
        json['product_name_tr'],
        json['product_name'],
        json['product_name_en'],
        json['generic_name'],
      ]),
      brand: _firstNonEmpty([json['brands']]).split(',').first.trim(),
      quantity: _firstNonEmpty([json['quantity']]),
      imageUrl:
          _nonEmptyOrNull(json['image_front_small_url']) ??
          _nonEmptyOrNull(json['image_front_url']),
      source: source,
      nutriScore: grade != null && 'abcde'.contains(grade) && grade.length == 1
          ? grade
          : null,
      novaGroup: (json['nova_group'] as num?)?.toInt(),
      additiveCodes: [
        for (final tag in _stringList(json['additives_tags']))
          tag.replaceFirst('en:', ''),
      ],
      allergens: [
        for (final tag in _stringList(json['allergens_tags']))
          _allergenName(tag),
      ],
      vegan: _dietStatus(tags, 'vegan'),
      vegetarian: _dietStatus(tags, 'vegetarian'),
      palmOilFree: tags.contains('en:palm-oil-free')
          ? DietStatus.yes
          : tags.contains('en:palm-oil')
          ? DietStatus.no
          : tags.contains('en:may-contain-palm-oil')
          ? DietStatus.maybe
          : DietStatus.unknown,
      nutrientLevels: {
        for (final nutrient in Nutrient.values)
          nutrient: ?NutrientLevel.fromName(levels[nutrient.apiKey]),
      },
      nutrientsPer100g: {
        for (final nutrient in Nutrient.values)
          if (nutriments['${nutrient.apiKey}_100g'] case final num value)
            nutrient: value.toDouble(),
      },
      energyKcalPer100g: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
      ingredientsText: _firstNonEmpty([
        json['ingredients_text_tr'],
        json['ingredients_text'],
        json['ingredients_text_en'],
      ]),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      source: ProductSource.fromName(json['source'] as String?),
      brand: json['brand'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      nutriScore: json['nutriScore'] as String?,
      novaGroup: (json['novaGroup'] as num?)?.toInt(),
      additiveCodes: _stringList(json['additives']),
      allergens: _stringList(json['allergens']),
      vegan: DietStatus.fromName(json['vegan']),
      vegetarian: DietStatus.fromName(json['vegetarian']),
      palmOilFree: DietStatus.fromName(json['palmOilFree']),
      nutrientLevels: {
        for (final nutrient in Nutrient.values)
          nutrient: ?NutrientLevel.fromName(
            (json['levels'] as Map?)?[nutrient.name],
          ),
      },
      nutrientsPer100g: {
        for (final nutrient in Nutrient.values)
          if ((json['nutrients'] as Map?)?[nutrient.name] case final num value)
            nutrient: value.toDouble(),
      },
      energyKcalPer100g: (json['energyKcal'] as num?)?.toDouble(),
      ingredientsText: json['ingredients'] as String? ?? '',
    );
  }

  final String code;
  final String name;
  final ProductSource source;
  final String brand;
  final String quantity;
  final String? imageUrl;
  final String? nutriScore;
  final int? novaGroup;
  final List<String> additiveCodes;
  final List<String> allergens;
  final DietStatus vegan;
  final DietStatus vegetarian;
  final DietStatus palmOilFree;
  final Map<Nutrient, NutrientLevel> nutrientLevels;
  final Map<Nutrient, double> nutrientsPer100g;
  final double? energyKcalPer100g;
  final String ingredientsText;

  String get displayName => name.isEmpty ? 'İsimsiz ürün' : name;

  bool get hasNutritionData =>
      nutriScore != null || novaGroup != null || nutrientLevels.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'source': source.name,
      'brand': brand,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'nutriScore': nutriScore,
      'novaGroup': novaGroup,
      'additives': additiveCodes,
      'allergens': allergens,
      'vegan': vegan.name,
      'vegetarian': vegetarian.name,
      'palmOilFree': palmOilFree.name,
      'levels': {
        for (final entry in nutrientLevels.entries)
          entry.key.name: entry.value.name,
      },
      'nutrients': {
        for (final entry in nutrientsPer100g.entries)
          entry.key.name: entry.value,
      },
      'energyKcal': energyKcalPer100g,
      'ingredients': ingredientsText,
    };
  }

  static DietStatus _dietStatus(List<String> tags, String diet) {
    if (tags.contains('en:$diet')) return DietStatus.yes;
    if (tags.contains('en:non-$diet')) return DietStatus.no;
    if (tags.contains('en:maybe-$diet')) return DietStatus.maybe;
    return DietStatus.unknown;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String) item,
    ];
  }

  static String _firstNonEmpty(List<Object?> candidates) {
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  static String? _nonEmptyOrNull(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static const Map<String, String> _allergenNames = {
    'gluten': 'Gluten',
    'crustaceans': 'Kabuklular',
    'eggs': 'Yumurta',
    'fish': 'Balık',
    'peanuts': 'Yer fıstığı',
    'soybeans': 'Soya',
    'milk': 'Süt',
    'nuts': 'Sert kabuklu yemişler',
    'celery': 'Kereviz',
    'mustard': 'Hardal',
    'sesame-seeds': 'Susam',
    'sulphur-dioxide-and-sulphites': 'Sülfitler',
    'lupin': 'Acı bakla',
    'molluscs': 'Yumuşakçalar',
  };

  static String _allergenName(String tag) {
    final key = tag.contains(':') ? tag.split(':').last : tag;
    return _allergenNames[key] ?? _humanize(tag);
  }

  static String _humanize(String tag) {
    final text = tag.contains(':') ? tag.split(':').last : tag;
    final words = text.replaceAll('-', ' ').trim();
    if (words.isEmpty) return words;
    return words[0].toUpperCase() + words.substring(1);
  }
}

@immutable
class ScanRecord {
  const ScanRecord({required this.product, required this.scannedAt});

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }

  final Product product;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'scannedAt': scannedAt.toIso8601String(),
  };
}
