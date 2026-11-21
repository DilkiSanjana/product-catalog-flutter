
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  List<Product> _products = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;

  String? _errorMessage;
  String? _paginationError;

  int _total = 0;
  int _skip = 0;

  static const int _pageSize = 10;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  String? get errorMessage => _errorMessage;
  String? get paginationError => _paginationError;

  bool get hasMore => _products.length < _total;

  Future<void> loadInitialProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _paginationError = null;
    _skip = 0;
    _products = [];

    notifyListeners();

    try {
      final page = await repository.getProducts(
        limit: _pageSize,
        skip: 0,
      );

      _products = page.products;
      _total = page.total;
      _skip = _products.length;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !hasMore) {
      return;
    }

    _isLoadingMore = true;
    _paginationError = null;

    notifyListeners();

    try {
      final page = await repository.getProducts(
        limit: _pageSize,
        skip: _skip,
      );

      _products = [..._products, ...page.products];
      _total = page.total;
      _skip = _products.length;
    } catch (error) {
      _paginationError = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await loadInitialProducts();
  }

  Future<void> retryLoadMore() async {
    await loadMoreProducts();
  }
}
