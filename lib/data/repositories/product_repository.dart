import 'package:dio/dio.dart';
import 'package:my_project/data/models/product.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  /// Fetch products with pagination (limit and offset)
  Future<List<Product>> fetchProducts({int page = 1, int limit = 20}) async {
    try {
      // Make the GET request to fetch products
      final response = await _dio.get('https://api.escuelajs.co/api/v1/products', queryParameters: {
        'page': page, // Current page
        'per_page': limit, // Number of products per page
      });

      final List<dynamic> data = response.data;

      // Convert JSON response to a list of Product objects
      return data.map((item) => Product.fromJson(item)).toList();
    } catch (error) {
      // Handle error and rethrow it to the notifier
      throw Exception('Failed to fetch products');
    }
  }
}
