
import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should correctly create a Product from JSON', () {
      final json = {
        'id': 1,
        'title': 'iPhone 15',
        'description': 'Apple smartphone',
        'price': 999.99,
        'rating': 4.8,
        'stock': 10,
        'thumbnail': 'https://example.com/image.jpg',
        'category': 'smartphones',
        'brand': 'Apple',
        'images': ['https://example.com/image.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'iPhone 15');
      expect(product.price, 999.99);
      expect(product.rating, 4.8);
      expect(product.stock, 10);
      expect(product.brand, 'Apple');
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': 2,
      };

      final product = Product.fromJson(json);

      expect(product.id, 2);
      expect(product.title, 'Unknown Product');
      expect(product.price, 0.0);
      expect(product.description, '');
      expect(product.stock, 0);
      expect(product.images, isEmpty);
    });
  });
}
