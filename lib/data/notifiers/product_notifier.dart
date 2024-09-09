// data/notifiers/product_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../domain/entities/entity.dart';

/// A simple state notifier for products
final productNotifierProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier(): super([]);
  final productRepository = ProductRepository(Dio());

  /// Loads products from the repository
  Future<void> loadProducts() async {
    final List<Product> products = await productRepository.fetchProducts();
    state = products;
  }

  /// Refreshes the products by clearing the current state and loading new products
  Future<void> refreshProducts() async {
    state = []; // Clear the current state
    await loadProducts(); // Load new products
  }
}