import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/repositories/product_repository.dart';

import '../../core/setup_get_it.dart';

final productNotifierProvider = Provider<ProductNotifier>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

class ProductNotifier {
  final ProductRepository _productRepository;
  static const _pageSize = 20;

  // Define the PagingController for managing pagination
  final PagingController<int, Product> pagingController =
  PagingController(firstPageKey: 1);

  ProductNotifier(this._productRepository) {
    // Set up the page request listener for PagingController
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  /// Fetch products for a specific page using PagingController
  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the products from the repository for the given page
      final newProducts = await _productRepository.fetchProducts(page: pageKey, limit: _pageSize);

      // Check if it's the last page (i.e., fewer products than the page size)
      final isLastPage = newProducts.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newProducts);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(newProducts, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  // Dispose the PagingController when no longer needed
  void dispose() {
    pagingController.dispose();
  }
}
