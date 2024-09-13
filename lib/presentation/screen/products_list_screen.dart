import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/widgets/products_list_body.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void dispose() {
    // Dispose the PagingController when no longer needed
    ref.read(productNotifierProvider).pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust AppBar content
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: screenWidth > 600
            ? [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality here for larger screens
              },
            ),
          ),
        ]
            : null, // No search button for smaller screens
      ),
      body: const ProductListBody(), // Display the product list
    );
  }
}
