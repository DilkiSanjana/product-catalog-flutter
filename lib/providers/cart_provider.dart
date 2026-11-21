
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': {
        'id': product.id,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'rating': product.rating,
        'stock': product.stock,
        'thumbnail': product.thumbnail,
        'category': product.category,
        'brand': product.brand,
        'images': product.images,
      },
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'saved_cart';

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount {
    return _items.values.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get totalPrice {
    return _items.values.fold(
      0.0,
      (total, item) => total + item.totalPrice,
    );
  }

  Future<void> loadCart() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedCart = preferences.getString(_cartKey);

      if (savedCart != null) {
        final decoded = jsonDecode(savedCart) as List<dynamic>;

        _items.clear();

        for (final item in decoded) {
          final cartItem = CartItem.fromJson(
            Map<String, dynamic>.from(item as Map),
          );

          _items[cartItem.product.id] = cartItem;
        }
      }
    } catch (error) {
      debugPrint('Failed to load cart: $error');
    }

    notifyListeners();
  }

  Future<void> _saveCart() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedCart = jsonEncode(
        _items.values.map((item) => item.toJson()).toList(),
      );

      await preferences.setString(_cartKey, savedCart);
    } catch (error) {
      debugPrint('Failed to save cart: $error');
    }
  }

  bool containsProduct(int productId) {
    return _items.containsKey(productId);
  }

  void addToCart(Product product) {
    final existingItem = _items[product.id];

    if (existingItem != null) {
      if (existingItem.quantity < product.stock) {
        existingItem.quantity++;
      }
    } else if (product.stock > 0) {
      _items[product.id] = CartItem(product: product);
    }

    notifyListeners();
    _saveCart();
  }

  void increaseQuantity(int productId) {
    final item = _items[productId];

    if (item == null || item.quantity >= item.product.stock) {
      return;
    }

    item.quantity++;
    notifyListeners();
    _saveCart();
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }

    notifyListeners();
    _saveCart();
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
    _saveCart();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
