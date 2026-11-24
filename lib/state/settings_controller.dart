import 'package:flutter/widgets.dart';

import '../core/theme/app_theme.dart';
import '../services/local_storage_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storage);

  final LocalStorageService _storage;

  AppThemeType _themeType = AppThemeType.premiumDark;

  AppThemeType get themeType => _themeType;

  void load({required Brightness platformBrightness}) {
    _themeType =
        AppThemeType.fromName(_storage.readThemeName()) ??
        (platformBrightness == Brightness.light
            ? AppThemeType.minimalLight
            : AppThemeType.premiumDark);
  }

  Future<bool> setThemeType(AppThemeType type) async {
    if (type == _themeType) return true;
    _themeType = type;
    notifyListeners();
    return _storage.writeThemeName(type.name);
  }

  Future<bool> toggleTheme() => setThemeType(_themeType.opposite);
}
