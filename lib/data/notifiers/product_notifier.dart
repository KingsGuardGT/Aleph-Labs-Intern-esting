// data/notifiers/product_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../core/setup_get_it.dart';

final productNotifierProvider = StateNotifierProvider<ProductNotifier, List<dynamic>>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

class ProductNotifier extends StateNotifier<List<dynamic>> {
  final ProductRepository _productRepository;

  int _currentPage = 1; // Start at page 1
  int _totalPages = 0; // Total pages
  bool _isLoading = false;
  bool _hasMore = true;

  ProductNotifier(this._productRepository) : super([]);

  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  /// Load products for the given page
  Future<void> loadProducts({int page = 1}) async {
    if (_isLoading) return;

    _isLoading = true;
    _currentPage = page; // Update current page

    try {
      // Fetch products for the current page
      final newProducts = await _productRepository.fetchProducts(page: _currentPage);

      if (newProducts.isEmpty) {
        _hasMore = false; // No more products available
      } else {
        // Set total pages manually (for this example), could come from API in a real case
        _totalPages = 10; // For example, assume 10 pages

        // Update the state
        state = [...newProducts];
      }
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Move to the next page (if not the last one)
  Future<void> nextPage() async {
    if (_currentPage < _totalPages) {
      await loadProducts(page: _currentPage + 1);
    }
  }

  /// Move to the previous page (if not the first one)
  Future<void> previousPage() async {
    if (_currentPage > 1) {
      await loadProducts(page: _currentPage - 1);
    }
  }

  /// Refresh the product list and reset pagination
  Future<void> refreshProducts() async {
    _currentPage = 1;
    _hasMore = true;
    state = [];
    await loadProducts(page: 1);
  }
}
