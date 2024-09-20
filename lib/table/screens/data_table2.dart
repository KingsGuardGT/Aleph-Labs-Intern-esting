import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../data/notifiers/product_notifier.dart';

class DataTable2Demo extends ConsumerWidget {
  const DataTable2Demo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.pagingController.itemList;

    return DataTable2(
      columns: [
        DataColumn2(
          label: const Text('ID'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) {
            if (products != null) {
              products.sort((a, b) => a.id.compareTo(b.id));
              ref.watch(productNotifierProvider);
            }
          },
        ),
        DataColumn2(
          label: const Text('Title'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) {
            if (products != null) {
              products.sort((a, b) => a.title.compareTo(b.title));
              ref.watch(productNotifierProvider);
            }
          },
        ),
        DataColumn2(
          label: const Text('Price'),
          size: ColumnSize.S,
          numeric: true,
          onSort: (columnIndex, ascending) {
            if (products != null) {
              products.sort((a, b) => a.price.compareTo(b.price));
              ref.watch(productNotifierProvider);
            }
          },
        ),
        // Add more columns as needed
      ],
      rows: products != null
          ? products.map((product) {
        return DataRow2(
          cells: [
            DataCell(Text(product.id.toString())),
            DataCell(Text(product.title)),
            DataCell(Text(product.price.toString())),
            // Add more cells as needed
          ],
        );
      }).toList()
          : [],
    );
  }
}