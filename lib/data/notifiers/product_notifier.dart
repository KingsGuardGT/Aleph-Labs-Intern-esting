// services/product_notifier.dart
import 'package:get_it/get_it.dart';
import '../repositories/product_repository.dart';
import '../models/product.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService(this._productRepository);

  Future<List<Product>> getProducts() async {
    return await _productRepository.fetchProducts();
  }
}