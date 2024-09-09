import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_expanded_item.dart';

final isExpandedProvider = StateProvider.family<bool, int>((ref, index) => false);

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