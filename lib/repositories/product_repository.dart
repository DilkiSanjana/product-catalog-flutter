
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

  Future<ProductPage> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final data = await apiService.fetchProducts(
      limit: limit,
      skip: skip,
    );

    final results = data['products'] as List<dynamic>? ?? [];

    final products = results
        .map((item) => Product.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();

    return ProductPage(
      products: products,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await apiService.searchProducts(query);

    final results = data['products'] as List<dynamic>? ?? [];

    return results
        .map((item) => Product.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<Product> getProductById(int id) async {
    final data = await apiService.fetchProductById(id);
    return Product.fromJson(data);
  }
}
