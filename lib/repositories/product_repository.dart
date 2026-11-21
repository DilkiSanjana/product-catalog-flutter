
import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductPage {
  final List<Product> products;
  final int total;

  const ProductPage({
    required this.products,
    required this.total,
  });
}

class ProductRepository {
  final ProductApiService apiService;

  ProductRepository({required this.apiService});

  List<Product> _parseProducts(Map<String, dynamic> data) {
    final results = data['products'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => Product.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  ProductPage _parseProductPage(Map<String, dynamic> data) {
    return ProductPage(
      products: _parseProducts(data),
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  Future<ProductPage> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final data = await apiService.fetchProducts(
      limit: limit,
      skip: skip,
    );

    return _parseProductPage(data);
  }

  Future<ProductPage> getProductsByCategory({
    required String category,
    int limit = 10,
    int skip = 0,
  }) async {
    final data = await apiService.fetchProductsByCategory(
      category: category,
      limit: limit,
      skip: skip,
    );

    return _parseProductPage(data);
  }

  Future<List<String>> getCategories() {
    return apiService.fetchCategories();
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await apiService.searchProducts(query);

    return _parseProducts(data);
  }

  Future<Product> getProductById(int id) async {
    final data = await apiService.fetchProductById(id);

    return Product.fromJson(data);
  }
}
