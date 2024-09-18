import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_expanded_item.dart';

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
    // Get the current expansion state for the specific product
    final isExpanded = ref.watch(isExpandedProvider(index));

    // Determine screen width to change layout based on the size
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // For tablet or web-sized screens

    // Ensure that we are using a valid URL for the image (null and array handling)
    final String? imageUrl = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first.replaceAll(RegExp(r'[\[\]\"]'), '') // Remove brackets and quotes
        : null; // Fallback if no image exists

    Widget buildImage() {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Container(
          width: isLargeScreen ? 150 : double.infinity,
          height: isLargeScreen ? 150 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        return SizedBox(
          width: isLargeScreen ? 150 : double.infinity,
          height: isLargeScreen ? 150 : 200,
          child: const Icon(Icons.image_not_supported),
        );
      }
    }

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title of the product
          Text(
            product.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Price of the product
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, color: Colors.green),
          ),
          const SizedBox(height: 8),

          // Description, shortened or expanded based on isExpanded
          Text(
            isExpanded
                ? product.description ?? '' // Full description
                : (product.description != null && product.description!.length > 50
                ? '${product.description!.substring(0, 50)}...' // Shortened description
                : product.description ?? ''), // Fallback for short description
          ),
          const SizedBox(height: 8),

          // Expand/Collapse Button
          IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              ref.read(isExpandedProvider(index).notifier).update((state) => !state);
            },
          ),

          // Conditionally render extra content if expanded
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
              // Ensure content does not overflow by wrapping it with Expanded
              Expanded(
                child: SingleChildScrollView(
                  child: buildContent(),
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildImage(),
              const SizedBox(height: 16),
              // Wrap in SingleChildScrollView to prevent overflow in small screens
              SingleChildScrollView(
                child: buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
