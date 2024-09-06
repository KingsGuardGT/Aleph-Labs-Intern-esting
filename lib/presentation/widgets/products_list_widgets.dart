import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';

import '../../core/setup_get_it.dart';

// This provider fetches the list of products from the repository.
final productListProvider = FutureProvider<List<Product>>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  return productRepository.fetchProducts();
});

// State provider for managing the expansion state for each product by its index.
final isExpandedProvider = StateProvider.family<bool, int>((ref, index) => false);

class ProductListBody extends ConsumerWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the product list async state.
    final productsAsyncValue = ref.watch(productListProvider);

    return productsAsyncValue.when(
      data: (products) => products.isEmpty
          ? const Center(child: Text('No products found.'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductListItem(
            product: product,
            index: index,
          );
        },
      ),
      error: (error, _) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class ProductListItem extends ConsumerWidget {
  final Product product;
  final int index; // Pass index for unique expansion state management

  const ProductListItem({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the expansion state for the current product based on index.
    final isExpanded = ref.watch(isExpandedProvider(index));

    return Column(
      children: [
        ListTile(
          title: Text(product.title),
          subtitle: Text('\$${product.price}'),
          trailing: IconButton(
            icon: isExpanded
                ? const Icon(Icons.expand_less)
                : const Icon(Icons.expand_more),
            color: Colors.green,
            onPressed: () {
              // Toggling the expansion state for the current product.
              ref
                  .read(isExpandedProvider(index).notifier)
                  .update((state) => !state);
            },
          ),
        ),
        // If expanded, show the expanded product details.
        if (isExpanded)
          ProductListExpandedItem(product: product),
      ],
    );
  }
}

class ProductListExpandedItem extends ConsumerWidget {
  final Product product;

  const ProductListExpandedItem({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${product.description}'),
          const SizedBox(height: 8),
          Text('Created At: ${product.createdAt}'),
          const SizedBox(height: 8),
          Text('Updated At: ${product.updatedAt}'),
          const SizedBox(height: 16),
          if (product.images != null)
            Column(
              children: product.images!.map((image) {
                String imageUrl = image.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(
                    imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Failed to load image');
                    },
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class ProductListFloatingActionButton extends ConsumerWidget {
  final Function onPressed;

  const ProductListFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => onPressed(),
      child: const Icon(Icons.refresh),
    );
  }
}
