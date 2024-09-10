// presentation/widgets/product_list_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';

import '../../data/models/product.dart';

class ProductListBody extends ConsumerStatefulWidget {
  const ProductListBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends ConsumerState<ProductListBody> {
  final _scrollController = ScrollController(); // Track scrolling

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Attach scroll listener
    ref.read(productNotifierProvider.notifier).loadProducts(); // Load initial products
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the scroll controller
    super.dispose();
  }

  /// Scroll listener to detect when the user reaches the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // User has scrolled to the bottom, so load more products
      ref.read(productNotifierProvider.notifier).nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(productNotifierProvider); // Watch the product list
    final isLoading = ref.watch(productNotifierProvider.notifier).isLoading;
    final currentPage = ref.watch(productNotifierProvider.notifier).currentPage;
    final hasMore = ref.watch(productNotifierProvider.notifier).hasMore;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: items.isNotEmpty ? items.length + (isLoading ? 1 : 0) : 1, // If empty, show a single item (empty state or loader)
            itemBuilder: (context, index) {
              if (items.isEmpty) {
                // Handle empty list state
                return const Center(
                  child: Text("No products available"),
                );
              }

              if (index < items.length) {
                final item = items[index];
                if (item is Product) {
                  // Render product item
                  return ProductListItem(
                    product: item,
                    index: index,
                  );
                }
              }

              // If it's the last index and we're loading more, show a loading spinner
              if (index == items.length && isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return const SizedBox.shrink(); // Avoid RangeError for invalid cases
            },
          ),
        ),
        // Page Navigation Controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentPage > 1
                    ? () => ref.read(productNotifierProvider.notifier).previousPage()
                    : null, // Disable button on the first page
                child: const Text('Previous Page'),
              ),
              Text('Page $currentPage'), // Display the current page number
              ElevatedButton(
                onPressed: hasMore
                    ? () => ref.read(productNotifierProvider.notifier).nextPage()
                    : null, // Disable button if no more pages
                child: const Text('Next Page'),
              ),
            ],
          ),
        ),
      ],
    );

  }
}
