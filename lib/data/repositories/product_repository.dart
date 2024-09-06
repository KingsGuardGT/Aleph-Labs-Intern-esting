// repositories/product_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/setup_get_it.dart';
import '../models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get('https://api.escuelajs.co/api/v1/products');
    return (response.data as List).map((product) => Product.fromJson(product)).toList();
  }

  getProducts() {}
}