// data/notifiers/product_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../domain/entities/entity.dart';


final productNotifierProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier(): super([]);
  final productRepository = ProductRepository(Dio());


  Future<void> loadProducts() async {
    final products = await productRepository.getProducts();
    if (products != null) {
      state = products;
    } else {
      state = []; // Set the state to an empty list if products is null
    }
  }
}