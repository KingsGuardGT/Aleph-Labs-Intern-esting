// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:my_project/data/notifiers/product_notifier.dart';
//
// class PaginationWidget extends ConsumerWidget {
//   const PaginationWidget({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final productNotifier = ref.watch(productNotifierProvider);
//     final currentPage = productNotifier.pagingController.nextPageKey != null
//         ? productNotifier.pagingController.nextPageKey! - 1
//         : 1; // Display the current page manually
//     final hasMore = productNotifier.pagingController.nextPageKey != null;
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed: currentPage > 1
//               ? () => ref.read(productNotifierProvider).previousPage()
//               : null, // Fetch previous page
//           child: const Text('Previous Page'),
//         ),
//         Text('Page $currentPage'),
//         ElevatedButton(
//           onPressed: hasMore
//               ? () => ref.read(productNotifierProvider).nextPage()
//               : null, // Fetch next page
//           child: const Text('Next Page'),
//         ),
//       ],
//     );
//   }
// }
