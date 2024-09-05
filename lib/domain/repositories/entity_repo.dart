import '../../data/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}