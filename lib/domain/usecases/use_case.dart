// domain/usecases/get_products.dart

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}