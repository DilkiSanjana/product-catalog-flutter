
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class CachedProductData {
  final List<Product> products;
  final int total;

  const CachedProductData({
    required this.products,
    required this.total,
  });
}

class ProductCacheService {
  static const String _cacheKey = 'cached_products';
  static const String _totalKey = 'cached_products_total';

  Future<void> saveProducts(
    List<Product> products, {
    required int total,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    final productsJson = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );

    await preferences.setString(_cacheKey, productsJson);
    await preferences.setInt(_totalKey, total);

    debugPrint('CACHE SAVED: ${products.length} products');
  }

  Future<CachedProductData?> loadProducts() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedProducts = preferences.getString(_cacheKey);

      debugPrint('CACHE FOUND: ${savedProducts != null}');

      if (savedProducts == null) {
        return null;
      }

      final decoded = jsonDecode(savedProducts) as List<dynamic>;

      final products = decoded.map((item) {
        return Product.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      if (products.isEmpty) {
        return null;
      }

      final total = preferences.getInt(_totalKey) ?? products.length;

      return CachedProductData(
        products: products,
        total: total,
      );
    } catch (error) {
      debugPrint('CACHE LOAD ERROR: $error');
      return null;
    }
  }

  Future<void> clearCache() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_cacheKey);
    await preferences.remove(_totalKey);
  }
}
