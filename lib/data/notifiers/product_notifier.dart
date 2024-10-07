
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../core/setup_get_it.dart'; // Assuming you have a DI setup with GetIt

final productNotifierProvider = ChangeNotifierProvider<ProductNotifier>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});


class ProductNotifier extends ChangeNotifier {
  final ProductRepository _productRepository;
  static const int _pageSize = 20;

  final PagingController<int, Product> pagingController = PagingController(firstPageKey: 1);
  List<Product> _sortedProducts = [];
  List<Product> _products = [];
  Product? _currentProduct;
  int? _currentIndex;
  bool _isSorting = false;
  String _errorMessage = '';

  ProductNotifier(this._productRepository) {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Product? get currentProduct => _currentProduct;
  int? get currentIndex => _currentIndex;
  List<Product> get sortedProducts => _sortedProducts;
  List<Product> get products => _products;
  bool get isSorting => _isSorting;
  String get errorMessage => _errorMessage;

  void setCurrentProduct(Product product, int index) {
    _currentProduct = product;
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newProducts = await fetchProducts(pageKey, _pageSize);
      _products.addAll(newProducts);
      final isLastPage = newProducts.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newProducts);
      } else {
        pagingController.appendPage(newProducts, pageKey + 1);
      }
      _errorMessage = '';
    } catch (error) {
      pagingController.error = error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<List<Product>> fetchProducts(int page, int limit) async {
    try {
      return await _productRepository.fetchProducts(page: page, limit: limit);
    } catch (error) {
      _errorMessage = 'Failed to fetch products: ${error.toString()}';
      return [];
    }
  }

  // Append new products to the PagingController

  // Sort the products and update the displayed list
  Future<void> sortProducts(Comparator<Product> comparator) async {
    _isSorting = true; // Mark that sorting is in progress
    notifyListeners();

    try {
      // Retrieve current product list and sort it
      final allProducts = pagingController.itemList ?? [];
      final sortedList = List<Product>.from(allProducts)..sort(comparator);

      // Update sorted products and the PagingController list
      updateSortedProducts(sortedList);
      _errorMessage = ''; // Reset error message on success
    } catch (error) {
      // Handle sorting errors
      _errorMessage = 'Error sorting products: ${error.toString()}';
    } finally {
      _isSorting = false; // Mark sorting as complete
      notifyListeners(); // Notify listeners after sorting is done
    }
  }

  Product getProduct(int index) {
    return _products[index];
  }

  // Update the list of sorted products
  void updateSortedProducts(List<Product> sortedProducts) {
    _sortedProducts = sortedProducts;
    pagingController.itemList = _sortedProducts; // Update the PagingController item list
    notifyListeners(); // Notify listeners about the change
  }

  // Clear cached product data
  Future<void> clearCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cached_products_page_')) {
        await prefs.remove(key); // Remove cached pages
      }
    }
  }

  // Refresh the products (clear cache and reload from the beginning)
  Future<void> refreshProducts() async {
    _errorMessage = ''; // Reset error message
    await clearCache(); // Clear all cached data
    pagingController.refresh(); // Refresh paging controller (reload from the first page)
    notifyListeners(); // Notify listeners about the refresh
  }



  @override
  void dispose() {
    pagingController.dispose(); // Clean up PagingController
    super.dispose(); // Call the parent dispose
  }

}

