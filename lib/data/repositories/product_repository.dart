// repositories/product_repository.dart
import 'package:dio/dio.dart';
import '../models/product.dart';

class ProductRepository {
  final Dio dio;

  ProductRepository(this.dio);

  Future<List<Product>> fetchProducts() async {
    final response = await dio.get('https://api.escuelajs.co/api/v1/products');
    return (response.data as List).map((product) => Product.fromJson(product)).toList();
  }
}