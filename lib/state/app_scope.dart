import 'package:flutter/widgets.dart';

import '../services/additive_catalog.dart';
import '../services/ads/ad_service.dart';
import '../services/local_storage_service.dart';
import '../services/product_api_service.dart';
import 'history_store.dart';
import 'settings_controller.dart';

class AppDependencies {
  AppDependencies({
    required this.history,
    required this.settings,
    required this.api,
    required this.additives,
    required this.ads,
  });

  final HistoryStore history;
  final SettingsController settings;
  final ProductApiService api;
  final AdditiveCatalog additives;
  final AdService ads;

  static Future<AppDependencies> initialize({
    required Brightness platformBrightness,
  }) async {
    final storage = await LocalStorageService.create();
    return AppDependencies(
      history: HistoryStore(storage),
      settings: SettingsController(storage)
        ..load(platformBrightness: platformBrightness),
      api: ProductApiService(),
      additives: await AdditiveCatalog.load(),
      ads: AdService(),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}

extension AppScopeContext on BuildContext {
  HistoryStore get history => AppScope.of(this).history;

  SettingsController get settings => AppScope.of(this).settings;

  ProductApiService get api => AppScope.of(this).api;

  AdditiveCatalog get additives => AppScope.of(this).additives;

  AdService get ads => AppScope.of(this).ads;
}
