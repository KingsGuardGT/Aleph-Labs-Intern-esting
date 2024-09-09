import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

// This provider fetches the list of products from the repository.
// final productListProvider = FutureProvider<List<Product>>((ref) {
//   final productRepository = ref.watch(productRepositoryProvider);
//   return productRepository.fetchProducts();
// });

// State provider for managing the expansion state for each product by its index.


class ProductListFloatingActionButton extends ConsumerWidget {
  const ProductListFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepository = ref.watch(productNotifierProvider.notifier);

    return FloatingActionButton(
      onPressed: () async {
        // Assuming you want to refresh the product list
        await productRepository.refreshProducts();
      },
      child: const Icon(Icons.refresh),
    );
  }
}
