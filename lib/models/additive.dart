import 'package:flutter/foundation.dart';

enum AdditiveRisk {
  high(
    label: 'Yüksek aşırı tüketim riski',
    shortLabel: 'Yüksek risk',
    weight: 15,
  ),
  moderate(label: 'Orta aşırı tüketim riski', shortLabel: 'Orta', weight: 7),
  low(
    label: 'Aşırı tüketim riski bulunmadı',
    shortLabel: 'Düşük risk',
    weight: 0,
  ),
  unknown(
    label: 'EFSA tarafından işaretlenmemiş',
    shortLabel: 'İşaretsiz',
    weight: 0,
  );

  const AdditiveRisk({
    required this.label,
    required this.shortLabel,
    required this.weight,
  });

  final String label;
  final String shortLabel;
  final int weight;

  static AdditiveRisk fromName(Object? name) => values.firstWhere(
    (risk) => risk.name == name,
    orElse: () => AdditiveRisk.unknown,
  );
}

@immutable
class Additive {
  const Additive({
    required this.code,
    required this.name,
    required this.classes,
    required this.risk,
  });

  factory Additive.fromCatalog(String code, Map<String, dynamic> json) {
    return Additive(
      code: code,
      name: json['n'] as String? ?? '',
      classes: [
        for (final item in json['c'] as List? ?? const [])
          if (item is String) item,
      ],
      risk: AdditiveRisk.fromName(json['r']),
    );
  }

  factory Additive.unlisted(String code) => Additive(
    code: code,
    name: 'Listede olmayan katkı',
    classes: const [],
    risk: AdditiveRisk.unknown,
  );

  final String code;
  final String name;
  final List<String> classes;
  final AdditiveRisk risk;

  String get displayCode => code.toUpperCase();

  String get role => classes.isEmpty ? 'Katkı maddesi' : classes.join(' · ');
}
