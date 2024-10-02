import 'dart:convert';
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
  bool _isSorting = false;
  String _errorMessage = '';

  ProductNotifier(this._productRepository) {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  List<Product> get sortedProducts => _sortedProducts;
  bool get isSorting => _isSorting;
  String get errorMessage => _errorMessage;

  // Fetch paginated data either from cache or API
  Future<void> _fetchPage(int pageKey) async {
    try {
      // First, try to load cached products
      final cachedProducts = await _getCachedData(pageKey);
      if (cachedProducts.isNotEmpty) {
        // If cached products exist, use them
        _appendPage(cachedProducts, pageKey);
      } else {
        // Otherwise, fetch fresh data from API
        final newProducts = await fetchProducts(pageKey, _pageSize);
        // Cache the fetched data
        await _cacheData(newProducts, pageKey);
        // Append the new products to the list
        _appendPage(newProducts, pageKey);
      }
      _errorMessage = ''; // Reset error message on success
    } catch (error) {
      // Handle errors gracefully and show the error message in the UI
      pagingController.error = error;
      _errorMessage = error.toString();
    }
    notifyListeners(); // Notify listeners only once after all operations
  }

  // Fetch products from the repository
  Future<List<Product>> fetchProducts(int page, int limit) async {
    try {
      return await _productRepository.fetchProducts(page: page, limit: limit);
    } catch (error) {
      _errorMessage = 'Failed to fetch products: ${error.toString()}';
      return [];
    }
  }

  // Append new products to the PagingController
  void _appendPage(List<Product> products, int pageKey) {
    final isLastPage = products.length < _pageSize;
    if (isLastPage) {
      pagingController.appendLastPage(products);
    } else {
      pagingController.appendPage(products, pageKey + 1);
    }
  }

  // Cache fetched data using SharedPreferences
  Future<void> _cacheData(List<Product> products, int page) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = await compute(_encodeProducts, products); // Offload encoding to a background isolate
    await prefs.setString('cached_products_page_$page', jsonString);
  }

  // Encode products for storage (using `compute` for large data)
  static String _encodeProducts(List<Product> products) {
    return jsonEncode(products.map((product) => product.toJson()).toList());
  }

  // Retrieve cached data from SharedPreferences
  Future<List<Product>> _getCachedData(int page) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_products_page_$page');
    if (jsonString != null) {
      final List<dynamic> jsonData = await compute(_decodeJson, jsonString); // Offload decoding to a background isolate
      return jsonData.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  // Decode JSON data (using `compute` for large data)
  static List<dynamic> _decodeJson(String jsonString) {
    return jsonDecode(jsonString);
  }

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

