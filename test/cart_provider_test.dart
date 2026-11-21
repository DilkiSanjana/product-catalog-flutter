
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/providers/cart_provider.dart';

void main() {
  late CartProvider cartProvider;
  late Product testProduct;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    cartProvider = CartProvider();

    testProduct = const Product(
      id: 1,
      title: 'Test Product',
      description: 'Test description',
      price: 100.0,
      rating: 4.5,
      stock: 10,
      thumbnail: 'https://example.com/image.jpg',
      category: 'test',
      brand: 'Test Brand',
      images: [],
    );
  });

  group('Cart Provider Tests', () {
    test('should add a product to cart', () async {
      cartProvider.addToCart(testProduct);

      expect(cartProvider.itemCount, 1);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, 1);

      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    });

    test('should increase quantity when adding same product', () async {
      cartProvider.addToCart(testProduct);
      cartProvider.addToCart(testProduct);

      expect(cartProvider.itemCount, 2);
      expect(cartProvider.items.first.quantity, 2);

      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    });

    test('should calculate total price correctly', () async {
      cartProvider.addToCart(testProduct);
      cartProvider.addToCart(testProduct);

      expect(cartProvider.totalPrice, 200.0);

      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    });

    test('should remove product from cart', () async {
      cartProvider.addToCart(testProduct);
      cartProvider.removeFromCart(testProduct.id);

      expect(cartProvider.itemCount, 0);
      expect(cartProvider.items, isEmpty);

      await Future<void>.delayed(
        const Duration(milliseconds: 100),
      );
    });
  });
}
