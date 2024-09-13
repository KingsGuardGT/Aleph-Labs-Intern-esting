import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

class ProductListBody extends ConsumerWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.watch(productNotifierProvider);
    final pagingController = productNotifier.pagingController;

    // Use MediaQuery to determine screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoint for switching to grid (e.g., 600px for web/tablets)
    final isLargeScreen = screenWidth > 600;

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => pagingController.refresh()),  // Refresh the entire list
      child: PagedListView<int, Product>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Product>(
          animateTransitions: true,
          itemBuilder: (context, product, index) {
            // For larger screens, display items in a grid
            if (isLargeScreen) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1200 ? 4 : 2,  // Switch between 2 or 4 columns based on screen width
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1 / 1.5,  // Control height/width ratio for grid items
                  ),
                  itemCount: pagingController.itemList?.length ?? 0,
                  itemBuilder: (context, gridIndex) {
                    final product = pagingController.itemList?[gridIndex];
                    return ProductListItem(
                      product: product!,
                      index: gridIndex,
                    );
                  },
                ),
              );
            }

            // For smaller screens (mobile), keep the list view
            return ProductListItem(
              product: product,
              index: index,
            );
          },
          firstPageProgressIndicatorBuilder: (_) => const Center(
            child: CircularProgressIndicator(),  // Loading indicator for the first page
          ),
          newPageProgressIndicatorBuilder: (_) => const Center(
            child: CircularProgressIndicator(),  // Loading indicator for additional pages
          ),
          firstPageErrorIndicatorBuilder: (context) => const Center(
            child: Text("Error loading products."),  // Error state for the first page
          ),
          noItemsFoundIndicatorBuilder: (context) => const Center(
            child: Text("No products available."),  // Empty state if no items are found
          ),
        ),
      ),
    );
  }
}
