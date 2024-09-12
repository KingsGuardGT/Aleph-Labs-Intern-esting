import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';
import 'package:my_project/presentation/widgets/products_list_pagination.dart';


class ProductListBody extends ConsumerWidget {
  const ProductListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.watch(productNotifierProvider);
    final pagingController = productNotifier.pagingController;

    return Column(
      children: [
        Expanded(
          child: PagedListView<int, Product>(
            pagingController: pagingController, // Attach the PagingController
            builderDelegate: PagedChildBuilderDelegate<Product>(
              itemBuilder: (context, product, index) => ProductListItem(
                product: product,
                index: index,
              ),
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
        // Manual Pagination Buttons
        // const PaginationWidget(),
      ],
    );
  }
}
