
import '../models/product.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  final ProductApiService apiService;

  ProductRepository({required this.apiService});

  Future<List<Product>> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final data = await apiService.fetchProducts(
      limit: limit,
      skip: skip,
    );

    final List<dynamic> results = data['products'] ?? [];

    return results
        .map((item) => Product.fromJson(item))
        .toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await apiService.searchProducts(query);

    final List<dynamic> results = data['products'] ?? [];

    return results
        .map((item) => Product.fromJson(item))
        .toList();
  }

  Future<Product> getProductById(int id) async {
    final data = await apiService.fetchProductById(id);

    return Product.fromJson(data);
  }
}
