import 'dart:convert';

import 'package:etiketdedektifi/core/theme/app_theme.dart';
import 'package:etiketdedektifi/core/utils/app_date_utils.dart';
import 'package:etiketdedektifi/features/product/screens/product_screen.dart';
import 'package:etiketdedektifi/services/additive_catalog.dart';
import 'package:etiketdedektifi/services/ads/ad_service.dart';
import 'package:etiketdedektifi/services/local_storage_service.dart';
import 'package:etiketdedektifi/services/product_api_service.dart';
import 'package:etiketdedektifi/state/app_scope.dart';
import 'package:etiketdedektifi/state/history_store.dart';
import 'package:etiketdedektifi/state/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppDependencies> _dependencies(http.Client client) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await LocalStorageService.create();
  return AppDependencies(
    history: HistoryStore(storage),
    settings: SettingsController(storage),
    api: ProductApiService(client: client),
    additives: AdditiveCatalog.fromMap({
      'e250': {
        'n': 'Sodyum nitrit',
        'c': ['Preservative'],
        'r': 'high',
      },
    }),
    ads: AdService(),
  );
}

Widget _host(AppDependencies dependencies) => AppScope(
  dependencies: dependencies,
  child: MaterialApp(
    theme: AppTheme.dark,
    home: const ProductScreen(barcode: '3017624010701'),
  ),
);

void main() {
  setUpAll(() => initializeDateFormatting(AppDateFormatter.locale));

  testWidgets('loads a product, shows the verdict and saves history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final client = MockClient((request) async {
      expect(request.headers['User-Agent'], contains('EtiketDedektifi'));
      return http.Response(
        jsonEncode({
          'status': 1,
          'product': {
            'product_name': 'Nutella',
            'brands': 'Ferrero',
            'nutriscore_grade': 'e',
            'nova_group': 4,
            'additives_tags': ['en:e250'],
            'nutrient_levels': {'sugars': 'high'},
            'nutriments': {'sugars_100g': 56.3},
          },
        }),
        200,
      );
    });
    final dependencies = await _dependencies(client);

    await tester.pumpWidget(_host(dependencies));
    expect(find.text('Etiket çözümleniyor…'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Nutella'), findsOneWidget);
    expect(find.text('Sınırlamak daha iyi'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sodyum nitrit'), 200);
    expect(find.text('Yüksek risk'), findsOneWidget);
    expect(dependencies.history.records.single.product.name, 'Nutella');
  });

  testWidgets('shows not found when no database has the barcode', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode({'status': 0}), 200),
    );
    await tester.pumpWidget(_host(await _dependencies(client)));
    await tester.pumpAndSettle();
    expect(find.text('Ürün bulunamadı'), findsOneWidget);
  });

  testWidgets('offers a retry when the request fails', (tester) async {
    final client = MockClient((_) async => http.Response('oops', 500));
    await tester.pumpWidget(_host(await _dependencies(client)));
    await tester.pumpAndSettle();
    expect(find.text('Ürün yüklenemedi'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
  });
}
