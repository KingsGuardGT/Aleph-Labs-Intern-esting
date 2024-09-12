import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

class ProductListFloatingActionButton extends ConsumerWidget {
  const ProductListFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //ref.watch(productNotifierProvider);

    return FloatingActionButton(
      onPressed: () {
        // Refresh the PagingController by refreshing the entire product list
        ref.read(productNotifierProvider).pagingController.refresh();
      },
      child: const Icon(Icons.refresh),
    );
  }
}
