import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';

import '../../main.dart';

class ProductListExpandedItem extends ConsumerWidget {
  final Product product;

  const ProductListExpandedItem({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);  // Watch the theme provider

    return Theme(
      data: theme,  // Apply the theme here
      child: Container(
        padding: const EdgeInsets.all(16),  // Fixed padding
        color: theme.colorScheme.surface,  // Use themed color for the background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.images != null && product.images!.isNotEmpty)
              Column(
                children: product.images!.map((image) {
                  String imageUrl = image.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),  // Fixed padding
                    child: Image.network(
                      imageUrl,  // Load the actual image URL
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Failed to load image');  // Fallback if image loading fails
                      },
                      width: 200,  // Fixed width
                      height: 200,  // Fixed height
                      fit: BoxFit.cover,  // Ensure the image covers the available area
                    ),
                  );
                }).toList(),
              ),
            if (product.images == null || product.images!.isEmpty)
              const Text('No images available'),  // Show a fallback message if no images are available
          ],
        ),
      ),
    );
  }
}