// products_cache.dart
import '../../data/models/product.dart';

class ProductCache {
  final Map<int, List<Product>> _cache = {};

  List<Product>? getProducts(int page) {
    return _cache[page];
  }

  void saveProducts(int page, List<Product> products) {
    _cache[page] = products;
  }

  void clearCache() {
    _cache.clear();
  }
}
