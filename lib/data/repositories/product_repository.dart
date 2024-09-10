// data/repositories/product_repository.dart

import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  /// Fetch products with pagination (limit and offset)
  Future<List<Product>> fetchProducts({int page = 1, int limit = 10}) async {
    // Offset-based pagination (API-specific)
    final response = await _dio.get('https://api.escuelajs.co/api/v1/products', queryParameters: {
      'offset': (page - 1) * limit, // Calculate the offset
      'limit': limit, // Limit number of products per request
    });

    final List<dynamic> data = response.data;

    return data.map((item) => Product.fromJson(item)).toList();
  }
}
