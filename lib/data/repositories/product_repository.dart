import 'package:dio/dio.dart';
import 'package:my_project/data/models/product.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<Product>> fetchProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        'https://api.escuelajs.co/api/v1/products',
        queryParameters: {
          'page': page,
          'per_page': limit,
        },
      );

      final List<dynamic> data = response.data;
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (error) {
      throw Exception('Failed to fetch products');
    }
  }
}

