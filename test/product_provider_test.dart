
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/providers/product_provider.dart';
import 'package:product_catalog/repositories/product_repository.dart';
import 'package:product_catalog/services/product_api_service.dart';

// ---------------------------------------------------------------------------
// Fake repository — returns controlled data without any HTTP calls.
// ---------------------------------------------------------------------------

class _FakeProductRepository extends ProductRepository {
  final List<Product> productsToReturn;
  final int totalToReturn;
  final bool shouldThrow;

  _FakeProductRepository({
    this.productsToReturn = const [],
    this.totalToReturn = 0,
    this.shouldThrow = false,
  }) : super(apiService: ProductApiService());

  @override
  Future<ProductPage> getProducts({int limit = 10, int skip = 0}) async {
    if (shouldThrow) throw Exception('Network error');
    return ProductPage(products: productsToReturn, total: totalToReturn);
  }

  @override
  Future<ProductPage> getProductsByCategory({
    required String category,
    int limit = 10,
    int skip = 0,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    return ProductPage(products: productsToReturn, total: totalToReturn);
  }

  @override
  Future<List<String>> getCategories() async {
    return ['smartphones', 'laptops', 'fragrances'];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    if (shouldThrow) throw Exception('Network error');
    return productsToReturn
        .where(
          (p) => p.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Product> _makeProducts(int count) {
  return List.generate(
    count,
    (i) => Product(
      id: i + 1,
      title: 'Product ${i + 1}',
      description: 'Description ${i + 1}',
      price: (i + 1) * 10.0,
      rating: (i % 5) + 1.0,
      stock: 10,
      thumbnail: 'https://example.com/image${i + 1}.jpg',
      category: 'smartphones',
      brand: 'Brand ${i + 1}',
      images: [],
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProductProvider – initial state', () {
    test('starts with empty products and no error', () {
      final provider = ProductProvider(
        repository: _FakeProductRepository(),
      );

      expect(provider.products, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.selectedCategory, isNull);
      expect(provider.sortOption, 'none');
    });
  });

  group('ProductProvider – loadInitialProducts', () {
    test('populates products on success', () async {
      final fakeProducts = _makeProducts(5);

      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 5,
        ),
      );

      await provider.loadInitialProducts();

      expect(provider.products.length, 5);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('sets errorMessage on failure', () async {
      final provider = ProductProvider(
        repository: _FakeProductRepository(shouldThrow: true),
      );

      await provider.loadInitialProducts();

      expect(provider.products, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNotNull);
    });

    test('sets isLoading true during loading', () async {
      final fakeProducts = _makeProducts(3);
      bool wasLoading = false;

      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 3,
        ),
      );

      provider.addListener(() {
        if (provider.isLoading) wasLoading = true;
      });

      await provider.loadInitialProducts();

      expect(wasLoading, isTrue);
      expect(provider.isLoading, isFalse);
    });
  });

  group('ProductProvider – sorting', () {
    late ProductProvider provider;

    setUp(() async {
      provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: _makeProducts(5),
          totalToReturn: 5,
        ),
      );
      await provider.loadInitialProducts();
    });

    test('changeSortOption to priceLow sorts ascending by price', () {
      provider.changeSortOption('priceLow');
      final prices = provider.products.map((p) => p.price).toList();
      expect(prices, equals([...prices]..sort()));
    });

    test('changeSortOption to priceHigh sorts descending by price', () {
      provider.changeSortOption('priceHigh');
      final prices = provider.products.map((p) => p.price).toList();
      expect(prices, equals([...prices]..sort((a, b) => b.compareTo(a))));
    });

    test('changeSortOption to ratingHigh sorts descending by rating', () {
      provider.changeSortOption('ratingHigh');
      final ratings = provider.products.map((p) => p.rating).toList();
      expect(ratings, equals([...ratings]..sort((a, b) => b.compareTo(a))));
    });

    test('changeSortOption to ratingLow sorts ascending by rating', () {
      provider.changeSortOption('ratingLow');
      final ratings = provider.products.map((p) => p.rating).toList();
      expect(ratings, equals([...ratings]..sort()));
    });

    test('changeSortOption updates sortOption getter', () {
      provider.changeSortOption('priceHigh');
      expect(provider.sortOption, 'priceHigh');
    });
  });

  group('ProductProvider – searchProducts', () {
    test('filters products matching the query', () async {
      final products = [
        Product(
          id: 1,
          title: 'iPhone 15',
          description: '',
          price: 999.0,
          rating: 4.8,
          stock: 10,
          thumbnail: '',
          category: 'smartphones',
          brand: 'Apple',
          images: [],
        ),
        Product(
          id: 2,
          title: 'Samsung Galaxy',
          description: '',
          price: 799.0,
          rating: 4.5,
          stock: 10,
          thumbnail: '',
          category: 'smartphones',
          brand: 'Samsung',
          images: [],
        ),
      ];

      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: products,
          totalToReturn: 2,
        ),
      );

      await provider.searchProducts('iphone');

      expect(provider.products.length, 1);
      expect(provider.products.first.title, 'iPhone 15');
    });

    test('restores full list when query is cleared', () async {
      final fakeProducts = _makeProducts(4);

      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 4,
        ),
      );

      await provider.loadInitialProducts();
      await provider.searchProducts('xyz');   // no match
      await provider.searchProducts('');      // clear → reload

      expect(provider.products.length, 4);
    });

    test('sets errorMessage when search API throws', () async {
      final provider = ProductProvider(
        repository: _FakeProductRepository(shouldThrow: true),
      );

      await provider.searchProducts('phone');

      expect(provider.errorMessage, isNotNull);
      expect(provider.isSearching, isFalse);
    });
  });

  group('ProductProvider – retry', () {
    test('retry with empty query calls loadInitialProducts', () async {
      final fakeProducts = _makeProducts(3);
      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 3,
        ),
      );

      await provider.retry();

      expect(provider.products.length, 3);
      expect(provider.errorMessage, isNull);
    });

    test('retry with non-empty query calls searchProducts', () async {
      final products = [
        Product(
          id: 1,
          title: 'Laptop Pro',
          description: '',
          price: 1200.0,
          rating: 4.7,
          stock: 5,
          thumbnail: '',
          category: 'laptops',
          brand: 'Dell',
          images: [],
        ),
      ];

      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: products,
          totalToReturn: 1,
        ),
      );

      // Prime the search query without awaiting (simulate a previous search).
      await provider.searchProducts('laptop');

      // Now retry should re-search.
      await provider.retry();

      expect(provider.products.length, 1);
      expect(provider.products.first.title, 'Laptop Pro');
    });
  });

  group('ProductProvider – category selection', () {
    test('selectCategory sets selectedCategory and reloads', () async {
      final fakeProducts = _makeProducts(2);
      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 2,
        ),
      );

      await provider.selectCategory('laptops');

      expect(provider.selectedCategory, 'laptops');
      expect(provider.products.length, 2);
    });

    test('selectCategory with null resets to all categories', () async {
      final fakeProducts = _makeProducts(5);
      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: fakeProducts,
          totalToReturn: 5,
        ),
      );

      await provider.selectCategory('laptops');
      await provider.selectCategory(null);

      expect(provider.selectedCategory, isNull);
    });
  });

  group('ProductProvider – hasMore pagination flag', () {
    test('hasMore is true when loaded products < total', () async {
      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: _makeProducts(5),
          totalToReturn: 20, // more pages available
        ),
      );

      await provider.loadInitialProducts();

      expect(provider.hasMore, isTrue);
    });

    test('hasMore is false when all products loaded', () async {
      final provider = ProductProvider(
        repository: _FakeProductRepository(
          productsToReturn: _makeProducts(5),
          totalToReturn: 5,
        ),
      );

      await provider.loadInitialProducts();

      expect(provider.hasMore, isFalse);
    });
  });
}
