import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../scanner/screens/scanner_screen.dart';
import 'screens/product_screen.dart';

abstract final class ProductNavigation {
  static Future<void> openBarcode(BuildContext context, String barcode) {
    return _pushProduct(Navigator.of(context), barcode);
  }

  static Future<void> openProduct(BuildContext context, Product product) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProductScreen(barcode: product.code, initialProduct: product),
      ),
    );
  }

  static Future<void> openScanner(BuildContext context) async {
    final navigator = Navigator.of(context);
    final barcode = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (barcode != null) await _pushProduct(navigator, barcode);
  }

  static Future<void> replaceWithScanner(BuildContext context) async {
    final navigator = Navigator.of(context);
    final barcode = await navigator.pushReplacement<String, void>(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (barcode != null) await _pushProduct(navigator, barcode);
  }

  static Future<void> _pushProduct(NavigatorState navigator, String barcode) {
    return navigator.push(
      MaterialPageRoute<void>(builder: (_) => ProductScreen(barcode: barcode)),
    );
  }
}
