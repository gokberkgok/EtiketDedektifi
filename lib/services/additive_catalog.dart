import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/additive.dart';

class AdditiveCatalog {
  AdditiveCatalog._(this._entries);

  static const String _assetPath = 'assets/data/additives.json';

  final Map<String, Map<String, dynamic>> _entries;

  static Future<AdditiveCatalog> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AdditiveCatalog._({
      for (final entry in decoded.entries)
        if (entry.value is Map<String, dynamic>)
          entry.key: entry.value as Map<String, dynamic>,
    });
  }

  factory AdditiveCatalog.fromMap(Map<String, Map<String, dynamic>> entries) =>
      AdditiveCatalog._(entries);

  Additive resolve(String code) {
    final key = code.toLowerCase();
    final entry = _entries[key];
    return entry == null
        ? Additive.unlisted(key)
        : Additive.fromCatalog(key, entry);
  }

  List<Additive> resolveAll(Iterable<String> codes) {
    final additives = [for (final code in codes) resolve(code)];
    additives.sort((a, b) => a.risk.index.compareTo(b.risk.index));
    return additives;
  }
}
