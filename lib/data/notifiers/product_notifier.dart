import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../core/setup_get_it.dart';

final productNotifierProvider = ChangeNotifierProvider<ProductNotifier>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

class ProductNotifier extends ChangeNotifier {
  final ProductRepository _productRepository;
  static const int _pageSize = 20;

  // Define the PagingController for managing pagination
  final PagingController<int, Product> pagingController =
  PagingController(firstPageKey: 1);

  // New state variables
  List<Product> _sortedProducts = [];
  bool _isSorting = false;
  String _errorMessage = '';

  ProductNotifier(this._productRepository) {
    // Set up the page request listener for PagingController
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  // Getters for new state variables
  List<Product> get sortedProducts => _sortedProducts;
  bool get isSorting => _isSorting;
  String get errorMessage => _errorMessage;

  /// Fetch products for a specific page using PagingController
  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the products from the repository for the given page
      final newProducts = await _productRepository.fetchProducts(
        page: pageKey,
        limit: _pageSize,
      );

      // Check if it's the last page (i.e., fewer products than the page size)
      final isLastPage = newProducts.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newProducts); // Last page reached
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(newProducts, nextPageKey); // Fetch next page
      }

      _errorMessage = ''; // Clear any previous error messages
    } catch (error) {
      pagingController.error = error; // Set error state if fetching fails
      _errorMessage = error.toString(); // Update error message
    }
    notifyListeners();
  }

  // New method to update sorted products
  void updateSortedProducts(List<Product> sortedProducts) {
    _sortedProducts = sortedProducts;
    pagingController.itemList = _sortedProducts;
    notifyListeners();
  }

  // New method to handle sorting
  Future<void> sortProducts(Comparator<Product> comparator) async {
    _isSorting = true;
    notifyListeners();

    try {
      final allProducts = pagingController.itemList ?? [];
      final sortedList = List<Product>.from(allProducts)..sort(comparator);
      updateSortedProducts(sortedList);
    } catch (error) {
      _errorMessage = 'Error sorting products: ${error.toString()}';
    } finally {
      _isSorting = false;
      notifyListeners();
    }
  }

  // New method to refresh products
  Future<void> refreshProducts() async {
    _errorMessage = '';
    pagingController.refresh();
    notifyListeners();
  }

  // Dispose the PagingController when no longer needed
  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}