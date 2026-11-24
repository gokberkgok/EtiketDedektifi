import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/local_storage_service.dart';

class HistoryStore extends ChangeNotifier {
  HistoryStore(this._storage) : _records = _storage.readHistory();

  final LocalStorageService _storage;
  List<ScanRecord> _records;

  List<ScanRecord> get records => List.unmodifiable(_records);

  bool get isEmpty => _records.isEmpty;

  int countScannedOn(DateTime day) => _records
      .where(
        (record) =>
            record.scannedAt.year == day.year &&
            record.scannedAt.month == day.month &&
            record.scannedAt.day == day.day,
      )
      .length;

  Future<void> add(Product product) async {
    _records = await _storage.addToHistory(
      ScanRecord(product: product, scannedAt: DateTime.now()),
    );
    notifyListeners();
  }

  Future<void> remove(String code) async {
    _records = await _storage.removeFromHistory(code);
    notifyListeners();
  }

  Future<void> clear() async {
    await _storage.clearHistory();
    _records = [];
    notifyListeners();
  }
}
