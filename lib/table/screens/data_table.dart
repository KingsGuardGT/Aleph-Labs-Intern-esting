import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../data_sources.dart';
import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';

class DataTableDemo extends ConsumerStatefulWidget {
  const DataTableDemo({super.key});

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends ConsumerState<DataTableDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  final Set<int> _selectedProducts = {};

  void _sort<T>(
      Comparable<T> Function(Product p) getField,
      int columnIndex,
      bool ascending,
      ) {
    final products = ref.read(productNotifierProvider).pagingController.itemList;
    if (products != null) {
      products.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });

      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });

      ref.read(productNotifierProvider);
    }
  }

  void _onSelectAll(bool? selected) {
    final products = ref.read(productNotifierProvider).pagingController.itemList;
    setState(() {
      if (selected == true) {
        _selectedProducts.addAll(products!.map((product) => product.id));
      } else {
        _selectedProducts.clear();
      }
    });
  }

  void _onSelectedRow(bool? selected, int id) {
    setState(() {
      if (selected == true) {
        _selectedProducts.add(id);
      } else {
        _selectedProducts.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.pagingController.itemList;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Theme(
        data: ThemeData(
          iconTheme: const IconThemeData(color: Colors.white),
          scrollbarTheme: ScrollbarThemeData(
            thickness: WidgetStateProperty.all(5),
          ),
        ),
        child: DataTable2(
          headingRowColor:
          WidgetStateProperty.resolveWith((states) => Colors.grey[850]!),
          headingTextStyle: const TextStyle(color: Colors.white),
          headingCheckboxTheme: const CheckboxThemeData(
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
          isHorizontalScrollBarVisible: true,
          isVerticalScrollBarVisible: true,
          columnSpacing: 12,
          horizontalMargin: 12,
          sortArrowIcon: Icons.keyboard_arrow_up,
          sortArrowAnimationDuration: const Duration(milliseconds: 500),
          border: TableBorder.all(color: Colors.grey[300]!),
          columns: [
            DataColumn2(
              label: const Text('ID'),
              size: ColumnSize.S,
              onSort: (columnIndex, ascending) {
                _sort<num>((product) => product.id, columnIndex, ascending);
              },
            ),
            DataColumn2(
              label: const Text('Title'),
              size: ColumnSize.S,
              onSort: (columnIndex, ascending) {
                _sort<String>((product) => product.title, columnIndex, ascending);
              },
            ),
            DataColumn2(
              label: const Text('Price'),
              size: ColumnSize.S,
              numeric: true,
              onSort: (columnIndex, ascending) {
                _sort<num>((product) => product.price, columnIndex, ascending);
              },
            ),
            // Add more columns as needed
          ],
          rows: products != null
              ? products.map((product) {
            return DataRow2(
              selected: _selectedProducts.contains(product.id),
              onSelectChanged: (selected) {
                _onSelectedRow(selected, product.id);
              },
              cells: [
                DataCell(Text(product.id.toString())),
                DataCell(Text(product.title)),
                DataCell(Text('\$${product.price}')),
                // Add more cells as needed
              ],
            );
          }).toList()
              : [],
          empty: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[200],
              child: const Text('No data'),
            ),
          ),
        ),
      ),
    );
  }
}