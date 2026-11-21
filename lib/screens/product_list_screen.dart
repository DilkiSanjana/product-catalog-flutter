
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import '../providers/favorite_provider.dart';
import 'favorites_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {
  final ScrollController _scrollController =
      ScrollController();

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProductProvider>().loadCategories();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context.read<ProductProvider>().searchProducts(query);
      },
    );
  }

  void _onCategoryChanged(String? category) {
    _debounce?.cancel();
    _searchController.clear();

    context.read<ProductProvider>().selectCategory(
          category == null || category.isEmpty
              ? null
              : category,
        );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          // Favorites button
  Consumer<FavoriteProvider>(
    builder: (context, favoriteProvider, child) {
      return IconButton(
        tooltip: 'My Favorites',
        icon: Badge(
          label: Text('${favoriteProvider.favoriteCount}'),
          isLabelVisible: favoriteProvider.favoriteCount > 0,
          child: const Icon(Icons.favorite),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesScreen(),
            ),
          );
        },
      );
    },
  ),

  // Shopping cart button
  Consumer<CartProvider>(
    builder: (context, cartProvider, child) {
      return IconButton(
        icon: Badge(
          label: Text('${cartProvider.itemCount}'),
          isLabelVisible: cartProvider.itemCount > 0,
          child: const Icon(Icons.shopping_cart),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ),
          );
        },
      );
    },
  ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surface,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterControls(provider),
          Expanded(
            child: _buildProducts(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: provider.selectedCategory ?? '',
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('All Categories'),
                ),
                ...provider.categories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: provider.isLoadingCategories
                  ? null
                  : _onCategoryChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: provider.sortOption,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'none',
                  child: Text('Default'),
                ),
                DropdownMenuItem(
                  value: 'priceLow',
                  child: Text('Price: Low to High'),
                ),
                DropdownMenuItem(
                  value: 'priceHigh',
                  child: Text('Price: High to Low'),
                ),
                DropdownMenuItem(
                  value: 'ratingHigh',
                  child: Text('Rating: High to Low'),
                ),
                DropdownMenuItem(
                  value: 'ratingLow',
                  child: Text('Rating: Low to High'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.changeSortOption(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProducts(ProductProvider provider) {
    if ((provider.isLoading || provider.isSearching) &&
        provider.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: provider.retry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.products.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: provider.products.length +
          (provider.isLoadingMore ||
                  provider.paginationError != null
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index < provider.products.length) {
          return ProductCard(
            product: provider.products[index],
          );
        }

        if (provider.paginationError != null) {
          return Center(
            child: TextButton(
              onPressed: provider.retryLoadMore,
              child: const Text('Failed to load. Retry'),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
