
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  ProductProvider({required this.repository});

  List<Product> _products = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;

  String? _errorMessage;
  String? _paginationError;

  String _searchQuery = '';

  int _total = 0;
  int _skip = 0;

  static const int _pageSize = 10;

  List<Product> get products => _products;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;
  String? get paginationError => _paginationError;

  String get searchQuery => _searchQuery;

  bool get hasMore => _searchQuery.isEmpty && _products.length < _total;

  Future<void> loadInitialProducts() async {
    _searchQuery = '';
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

  Future<void> searchProducts(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      await loadInitialProducts();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    _paginationError = null;
    _products = [];

    notifyListeners();

    try {
      final results = await repository.searchProducts(_searchQuery);

      _products = results;
      _total = results.length;
      _skip = results.length;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_searchQuery.isNotEmpty) {
      await searchProducts(_searchQuery);
    } else {
      await loadInitialProducts();
    }
  }

  Future<void> retryLoadMore() async {
    await loadMoreProducts();
  }
}