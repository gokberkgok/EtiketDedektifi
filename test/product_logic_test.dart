import 'package:etiketdedektifi/models/additive.dart';
import 'package:etiketdedektifi/models/product.dart';
import 'package:etiketdedektifi/services/additive_catalog.dart';
import 'package:etiketdedektifi/services/local_storage_service.dart';
import 'package:etiketdedektifi/services/product_api_service.dart';
import 'package:etiketdedektifi/services/product_score.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, dynamic> _nutellaJson = {
  'code': '3017624010701',
  'product_name': 'Nutella',
  'brands': 'Ferrero, Nutella',
  'quantity': '400 g',
  'nutriscore_grade': 'e',
  'nova_group': 4,
  'additives_tags': ['en:e322', 'en:e250'],
  'allergens_tags': ['en:nuts', 'en:milk'],
  'ingredients_analysis_tags': ['en:palm-oil', 'en:non-vegan', 'en:vegetarian'],
  'nutrient_levels': {
    'fat': 'high',
    'saturated-fat': 'high',
    'sugars': 'high',
    'salt': 'low',
  },
  'nutriments': {
    'energy-kcal_100g': 539,
    'fat_100g': 30.9,
    'saturated-fat_100g': 10.6,
    'sugars_100g': 56.3,
    'salt_100g': 0.1075,
  },
  'ingredients_text': 'sugar, palm oil, hazelnuts',
};

AdditiveCatalog _catalog() => AdditiveCatalog.fromMap({
  'e322': {
    'n': 'Lecithins',
    'c': ['Emulsifier'],
    'r': 'unknown',
  },
  'e250': {
    'n': 'Sodium nitrite',
    'c': ['Preservative'],
    'r': 'high',
  },
});

void main() {
  group('Product.fromApi', () {
    test('maps Open Food Facts fields', () {
      final product = Product.fromApi(_nutellaJson, ProductSource.food);
      expect(product.name, 'Nutella');
      expect(product.brand, 'Ferrero');
      expect(product.nutriScore, 'e');
      expect(product.novaGroup, 4);
      expect(product.additiveCodes, ['e322', 'e250']);
      expect(product.allergens, ['Sert kabuklu yemişler', 'Süt']);
      expect(product.vegan, DietStatus.no);
      expect(product.vegetarian, DietStatus.yes);
      expect(product.palmOilFree, DietStatus.no);
      expect(product.nutrientLevels[Nutrient.sugars], NutrientLevel.high);
      expect(product.nutrientsPer100g[Nutrient.salt], 0.1075);
      expect(product.energyKcalPer100g, 539);
    });

    test('survives a JSON round trip for offline history', () {
      final product = Product.fromApi(_nutellaJson, ProductSource.food);
      final restored = Product.fromJson(product.toJson());
      expect(restored.toJson(), product.toJson());
    });
  });

  group('ProductScorer', () {
    test('penalises Nutri-Score E, NOVA 4 and flagged additives', () {
      final product = Product.fromApi(_nutellaJson, ProductSource.food);
      final score = ProductScorer.evaluate(product, _catalog());
      expect(score.value, 100 - 55 - 20 - AdditiveRisk.high.weight);
      expect(score.verdict, Verdict.limit);
    });

    test('rates a clean product as a great choice', () {
      final product = Product.fromApi({
        'code': '8690526069500',
        'product_name': 'Oats',
        'nutriscore_grade': 'a',
        'nova_group': 1,
      }, ProductSource.food);
      final score = ProductScorer.evaluate(product, _catalog());
      expect(score.value, 100);
      expect(score.verdict, Verdict.great);
    });

    test('reports missing data instead of guessing', () {
      final product = Product.fromApi({
        'code': '3600523307302',
        'product_name': 'Shampoo',
      }, ProductSource.beauty);
      final score = ProductScorer.evaluate(product, _catalog());
      expect(score.value, isNull);
      expect(score.verdict, Verdict.unknown);
    });
  });

  test('additive catalog sorts riskiest first and tolerates unknown codes', () {
    final additives = _catalog().resolveAll(['e322', 'e999', 'e250']);
    expect(additives.first.code, 'e250');
    expect(additives.map((additive) => additive.code), contains('e999'));
  });

  test('barcode validation accepts EAN/UPC lengths only', () {
    expect(ProductApiService.isValidBarcode('3017624010701'), isTrue);
    expect(ProductApiService.isValidBarcode('12345'), isFalse);
    expect(ProductApiService.isValidBarcode('30176240107ab'), isFalse);
  });

  test('history keeps one entry per product, newest first', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.create();
    final product = Product.fromApi(_nutellaJson, ProductSource.food);
    await storage.addToHistory(
      ScanRecord(product: product, scannedAt: DateTime(2026, 11, 1)),
    );
    final history = await storage.addToHistory(
      ScanRecord(product: product, scannedAt: DateTime(2026, 11, 2)),
    );
    expect(history, hasLength(1));
    expect(history.single.scannedAt, DateTime(2026, 11, 2));
  });
}
