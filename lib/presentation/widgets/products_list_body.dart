import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

import '../../main.dart';

class ProductListBody extends ConsumerWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = ref.read(productNotifierProvider).pagingController; // Use read instead of watch to avoid unnecessary rebuilds
    final theme = ref.watch(themeProvider); // Only theme needs to be watched

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => pagingController.refresh()),
      child: Theme(
        data: theme,
        child: isLargeScreen
            ? LayoutBuilder(
          builder: (context, constraints) {
            return PagedGridView<int, Product>(
              pagingController: pagingController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1 / 1.5,
              ),
              builderDelegate: PagedChildBuilderDelegate<Product>(
                animateTransitions: true,
                itemBuilder: (context, product, index) {
                  return ProductListItem(product: product, index: index);
                },
                firstPageProgressIndicatorBuilder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
                newPageProgressIndicatorBuilder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
                firstPageErrorIndicatorBuilder: (context) => const Center(
                  child: Text("Error loading products."),
                ),
                noItemsFoundIndicatorBuilder: (context) => const Center(
                  child: Text("No products available."),
                ),
              ),
            );
          },
        )
            : PagedListView<int, Product>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Product>(
            animateTransitions: true,
            itemBuilder: (context, product, index) {
              return ProductListItem(product: product, index: index);
            },
            firstPageProgressIndicatorBuilder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            firstPageErrorIndicatorBuilder: (context) => const Center(
              child: Text("Error loading products."),
            ),
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text("No products available."),
            ),
          ),
        ),
      ),
    );
  }
}
