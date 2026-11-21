
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  static const String _favoritesKey = 'saved_favorites';

  final Map<int, Product> _favorites = {};

  List<Product> get favorites => _favorites.values.toList();

  int get favoriteCount => _favorites.length;

  bool isFavorite(int productId) {
    return _favorites.containsKey(productId);
  }

  Future<void> loadFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedFavorites = preferences.getString(_favoritesKey);

      if (savedFavorites != null) {
        final decoded = jsonDecode(savedFavorites) as List<dynamic>;

        _favorites.clear();

        for (final item in decoded) {
          final product = Product.fromJson(
            Map<String, dynamic>.from(item as Map),
          );

          _favorites[product.id] = product;
        }
      }
    } catch (error) {
      debugPrint('Failed to load favorites: $error');
    }

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedFavorites = jsonEncode(
        _favorites.values.map((product) => product.toJson()).toList(),
      );

      await preferences.setString(
        _favoritesKey,
        savedFavorites,
      );
    } catch (error) {
      debugPrint('Failed to save favorites: $error');
    }
  }

  void toggleFavorite(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }

    notifyListeners();
    _saveFavorites();
  }

  void removeFavorite(int productId) {
    _favorites.remove(productId);

    notifyListeners();
    _saveFavorites();
  }

  void clearFavorites() {
    _favorites.clear();

    notifyListeners();
    _saveFavorites();
  }
}
