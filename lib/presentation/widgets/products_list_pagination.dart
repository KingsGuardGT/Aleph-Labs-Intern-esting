import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifiers/product_notifier.dart';

class PaginationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.watch(productNotifierProvider.notifier);
    final currentPage = productNotifier.currentPage;
    final totalPages = productNotifier.totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1
              ? () => productNotifier.previousPage()
              : null,
          child: const Text('Previous Page'),
        ),
        Text('Page $currentPage of $totalPages'),
        ElevatedButton(
          onPressed: currentPage < totalPages
              ? () => productNotifier.nextPage()
              : null,
          child: const Text('Next Page'),
        ),
      ],
    );
  }
}