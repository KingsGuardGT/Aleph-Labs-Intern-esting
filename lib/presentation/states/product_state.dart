import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

final productNotifierProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

class ProductNotifier extends StateNotifier<List<Product>> {
  final ProductRepository _productRepository;

  ProductNotifier(this._productRepository) : super([]);

  Future<void> loadProducts() async {
    final products = await _productRepository.fetchProducts();
    state = products;
  }
}