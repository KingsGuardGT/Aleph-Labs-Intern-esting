import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';
import '../../core/utils/responsive_utils.dart';  // Import ResponsiveUtils
import '../../main.dart';

// lib/presentation/widgets/products_list_body.dart

// lib/presentation/widgets/products_list_body.dart

class ProductListBody extends ConsumerWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagingController = ref.read(productNotifierProvider).pagingController;
    final theme = ref.watch(themeProvider);

    int crossAxisCount = 1;
    if (ResponsiveUtils.isTablet(context)) {
      crossAxisCount = 2;
    } else if (ResponsiveUtils.isDesktop(context)) {
      crossAxisCount = 3;
    }

    return RefreshIndicator(
      onRefresh: () => Future.sync(() => pagingController.refresh()),
      child: Theme(
        data: theme,
        child: PagedGridView<int, Product>(
          pagingController: pagingController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1 / 1.5,
          ),
          builderDelegate: PagedChildBuilderDelegate<Product>(
            animateTransitions: true,
            itemBuilder: (context, product, index) {
              return ProductListItem(index: index);
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