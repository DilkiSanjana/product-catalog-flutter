
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/product_cache_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository;

  final ProductCacheService _cacheService = ProductCacheService();

  ProductProvider({required this.repository});

  List<Product> _products = [];
  List<String> _categories = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSearching = false;
  bool _isLoadingCategories = false;
  bool _isOfflineData = false;

  String? _errorMessage;
  String? _paginationError;
  String? _categoryError;

  String _searchQuery = '';
  String? _selectedCategory;

  String _sortOption = 'none';

  int _total = 0;
  int _skip = 0;

  static const int _pageSize = 10;

  List<Product> get products {
    final sortedProducts = List<Product>.from(_products);

    switch (_sortOption) {
      case 'priceLow':
        sortedProducts.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'priceHigh':
        sortedProducts.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'ratingHigh':
        sortedProducts.sort(
          (a, b) => b.rating.compareTo(a.rating),
        );
        break;

      case 'ratingLow':
        sortedProducts.sort(
          (a, b) => a.rating.compareTo(b.rating),
        );
        break;
    }

    return sortedProducts;
  }

  List<String> get categories => _categories;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isOfflineData => _isOfflineData;

  String? get errorMessage => _errorMessage;
  String? get paginationError => _paginationError;
  String? get categoryError => _categoryError;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  String get sortOption => _sortOption;

  bool get hasMore =>
      _products.length < _total && !_isSearching;

  // Load available categories.
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _categoryError = null;

    notifyListeners();

    try {
      _categories = await repository.getCategories();
    } catch (error) {
      _categoryError = error.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Select a category.
  Future<void> selectCategory(String? category) async {
    _selectedCategory = category;
    _searchQuery = '';

    await loadInitialProducts();
  }

  // Change sorting.
  void changeSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  // Load initial products.
  Future<void> loadInitialProducts() async {
    _isLoading = true;
    _errorMessage = null;
    _paginationError = null;
    _isOfflineData = false;
    _skip = 0;
    _total = 0;
    _products = [];

    notifyListeners();

    try {
      final page = _selectedCategory == null
          ? await repository.getProducts(
              limit: _pageSize,
              skip: 0,
            )
          : await repository.getProductsByCategory(
              category: _selectedCategory!,
              limit: _pageSize,
              skip: 0,
            );

      _products = page.products;
      _total = page.total;
      _skip = _products.length;

      // Save the default product catalog for offline use.
      if (_selectedCategory == null && _products.isNotEmpty) {
        await _cacheService.saveProducts(
          _products,
          total: _total,
        );
      }
    } catch (error) {
      // Use cached products if the default catalog cannot load.
      if (_selectedCategory == null) {
        try {
          final cachedData = await _cacheService.loadProducts();

          if (cachedData != null) {
            _products = cachedData.products;
            _total = cachedData.total;
            _skip = _products.length;
            _isOfflineData = true;
            _errorMessage = null;
          } else {
            _errorMessage = error.toString();
          }
        } catch (cacheError) {
          _errorMessage = error.toString();
        }
      } else {
        _errorMessage = error.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load the next page.
  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !hasMore || _isOfflineData) {
      return;
    }

    _isLoadingMore = true;
    _paginationError = null;

    notifyListeners();

    try {
      final page = _selectedCategory == null
          ? await repository.getProducts(
              limit: _pageSize,
              skip: _skip,
            )
          : await repository.getProductsByCategory(
              category: _selectedCategory!,
              limit: _pageSize,
              skip: _skip,
            );

      _products = [..._products, ...page.products];
      _total = page.total;
      _skip = _products.length;

      // Update the cache with all loaded default catalog products.
      if (_selectedCategory == null) {
        await _cacheService.saveProducts(
          _products,
          total: _total,
        );
      }
    } catch (error) {
      _paginationError = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Search products.
  Future<void> searchProducts(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      await loadInitialProducts();
      return;
    }

    _isSearching = true;
    _isOfflineData = false;
    _errorMessage = null;
    _paginationError = null;
    _products = [];

    notifyListeners();

    try {
      final results = await repository.searchProducts(_searchQuery);

      // Apply selected category to search results if necessary.
      _products = _selectedCategory == null
          ? results
          : results
              .where(
                (product) =>
                    product.category == _selectedCategory,
              )
              .toList();

      _total = _products.length;
      _skip = _products.length;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Retry initial loading or search.
  Future<void> retry() async {
    if (_searchQuery.isNotEmpty) {
      await searchProducts(_searchQuery);
    } else {
      await loadInitialProducts();
    }
  }

  // Retry pagination.
  Future<void> retryLoadMore() async {
    await loadMoreProducts();
  }
}
