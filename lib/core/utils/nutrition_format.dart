import 'package:intl/intl.dart';

abstract final class NutritionFormat {
  static final NumberFormat _oneDecimal = NumberFormat('0.#', 'tr_TR');

  static String grams(num value) =>
      value >= 10 ? '${value.round()} g' : '${_oneDecimal.format(value)} g';

  static String kcal(num value) => '${value.round()} kcal';
}
