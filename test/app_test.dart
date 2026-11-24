import 'package:etiketdedektifi/app.dart';
import 'package:etiketdedektifi/core/utils/app_date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => initializeDateFormatting(AppDateFormatter.locale));

  testWidgets('home renders and validates a typed barcode', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const EtiketDedektifiApp());
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.text('İçinde gerçekten ne var?').evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();

    expect(find.text('İçinde gerçekten ne var?'), findsOneWidget);
    expect(find.text('Henüz tarama yok'), findsOneWidget);

    await tester.tap(find.byTooltip('Barkodu yaz'));
    await tester.pumpAndSettle();
    expect(find.text('Barkod numarası'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Ürünü bul'));
    await tester.pumpAndSettle();
    expect(
      find.text('Barkodun altındaki 8–14 haneli numarayı gir.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geçmiş').last);
    await tester.pumpAndSettle();
    expect(find.text('Henüz ürün taranmadı'), findsOneWidget);
  });
}
