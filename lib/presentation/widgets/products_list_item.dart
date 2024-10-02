import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';  // Use CachedNetworkImage

import '../../main.dart';
import '../../data/models/product.dart';
import '../../presentation/widgets/products_list_expanded_item.dart';

// StateProvider for managing individual product expansion state based on index
final isExpandedProvider = StateProvider.family<bool, int>((ref, index) => false);

class ProductListItem extends ConsumerWidget {
  final Product product;
  final int index;

  const ProductListItem({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use `select` to watch only the necessary state (expansion state for this index)
    final isExpanded = ref.watch(isExpandedProvider(index).select((state) => state));
    final theme = ref.watch(themeProvider);  // Watch the theme provider

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    // Handle image URL more effectively
    final String? imageUrl = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first.replaceAll(RegExp(r'[\[\]\"]'), '')  // Ensure the URL is clean
        : null;

    Widget buildImage() {
      return imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        width: isLargeScreen ? 150 : double.infinity,
        height: isLargeScreen ? 150 : 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),  // Show a loading spinner while loading the image
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),  // Error icon when image fails to load
      )
          : SizedBox(
        width: isLargeScreen ? 150 : double.infinity,
        height: isLargeScreen ? 150 : 200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            isExpanded
                ? product.description ?? ''
                : (product.description != null && product.description!.length > 50
                ? '${product.description!.substring(0, 50)}...'
                : product.description ?? ''),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              ref.read(isExpandedProvider(index).notifier).update((state) => !state);
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ProductListExpandedItem(product: product),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        data: theme,
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLargeScreen
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                const SizedBox(width: 20),
                Expanded(
                  child: buildContent(),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                const SizedBox(height: 16),
                buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
