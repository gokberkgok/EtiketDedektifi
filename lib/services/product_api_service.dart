import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApiException implements Exception {
  const ProductApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductApiService {
  ProductApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _userAgent = 'EtiketDedektifi/1.0 (Android; Flutter)';
  static const Duration _timeout = Duration(seconds: 10);
  static const String _fields =
      'code,product_name,product_name_tr,product_name_en,generic_name,brands,'
      'quantity,'
      'image_front_small_url,image_front_url,nutriscore_grade,nova_group,'
      'additives_tags,allergens_tags,ingredients_analysis_tags,'
      'nutrient_levels,nutriments,ingredients_text,ingredients_text_tr,'
      'ingredients_text_en';
  static final RegExp _barcodePattern = RegExp(r'^\d{8,14}$');

  final http.Client _client;

  static bool isValidBarcode(String code) => _barcodePattern.hasMatch(code);

  Future<Product?> lookup(String barcode) async {
    final code = barcode.trim();
    if (!isValidBarcode(code)) {
      throw const ProductApiException(
        'Barkodlar 8–14 hanelidir. Lütfen numarayı kontrol et.',
      );
    }
    for (final source in ProductSource.values) {
      final product = await _fetch(source, code);
      if (product != null) return product;
    }
    return null;
  }

  Future<Product?> _fetch(ProductSource source, String code) async {
    final uri = Uri.https(source.host, '/api/v2/product/$code.json', {
      'fields': _fields,
    });
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
    } on TimeoutException {
      throw const ProductApiException(
        'Ürün veri tabanı yanıt vermekte gecikiyor. Lütfen tekrar dene.',
      );
    } on SocketException {
      throw const ProductApiException(
        'İnternet bağlantısı yok. Bağlanıp tekrar dene.',
      );
    } on http.ClientException {
      throw const ProductApiException(
        'Ürün veri tabanına ulaşılamadı. Lütfen tekrar dene.',
      );
    }

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ProductApiException(
        'Ürün veri tabanı bir hata döndürdü (${response.statusCode}).',
      );
    }

    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ProductApiException('Okunamayan bir yanıt alındı.');
    }
    if (body is! Map<String, dynamic>) return null;
    if (body['status'] != 1) return null;
    final product = body['product'];
    if (product is! Map<String, dynamic>) return null;
    return Product.fromApi({'code': code, ...product}, source);
  }
}
