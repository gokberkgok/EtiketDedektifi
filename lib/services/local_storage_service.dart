import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class LocalStorageService {
  LocalStorageService._(this._preferences);

  static const String _historyKey = 'scans.history.v1';
  static const String _themeKey = 'preferences.theme';
  static const int historyLimit = 40;

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    return LocalStorageService._(await SharedPreferences.getInstance());
  }

  List<ScanRecord> readHistory() {
    final raw = _preferences.getString(_historyKey);
    if (raw == null) return [];
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return [];
    }
    if (decoded is! List) return [];
    final records = <ScanRecord>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        records.add(ScanRecord.fromJson(entry));
      } catch (_) {
        continue;
      }
    }
    return records;
  }

  Future<List<ScanRecord>> addToHistory(ScanRecord record) async {
    final history = readHistory()
      ..removeWhere((item) => item.product.code == record.product.code)
      ..insert(0, record);
    final trimmed = history.take(historyLimit).toList();
    await _writeHistory(trimmed);
    return trimmed;
  }

  Future<List<ScanRecord>> removeFromHistory(String code) async {
    final history = readHistory()
      ..removeWhere((item) => item.product.code == code);
    await _writeHistory(history);
    return history;
  }

  Future<void> clearHistory() => _writeHistory(const []);

  String? readThemeName() => _preferences.getString(_themeKey);

  Future<bool> writeThemeName(String name) =>
      _preferences.setString(_themeKey, name);

  Future<void> _writeHistory(List<ScanRecord> history) async {
    final encoded = jsonEncode([for (final item in history) item.toJson()]);
    await _preferences.setString(_historyKey, encoded);
  }
}
