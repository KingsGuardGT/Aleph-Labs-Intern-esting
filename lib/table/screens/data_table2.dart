import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';

class DataTable2Demo extends ConsumerStatefulWidget {
  const DataTable2Demo({super.key});

  @override
  DataTable2DemoState createState() => DataTable2DemoState();
}

class DataTable2DemoState extends ConsumerState<DataTable2Demo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  Set<int> _selectedRows = {};

  void _sort<T>(
      Comparable<T> Function(Product p) getField,
      int columnIndex,
      bool ascending,
      ) {
    final productNotifier = ref.read(productNotifierProvider);
    final products = List<Product>.from(productNotifier.pagingController.itemList ?? []);

    products.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    productNotifier.updateSortedProducts(products);
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(imageUrl),
          ),
        ),
        backgroundColor: Colors.black,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.sortedProducts.isNotEmpty
        ? productNotifier.sortedProducts
        : productNotifier.pagingController.itemList;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (productNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                productNotifier.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Theme(
              data: ThemeData(
                iconTheme: const IconThemeData(color: Colors.white),
                scrollbarTheme: const ScrollbarThemeData(
                  thickness: WidgetStatePropertyAll(5),
                ),
              ),
              child: DataTable2(
                headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[850]!),
                headingTextStyle: const TextStyle(color: Colors.white),
                checkboxHorizontalMargin: 12,
                isHorizontalScrollBarVisible: true,
                isVerticalScrollBarVisible: true,
                columnSpacing: 12,
                horizontalMargin: 12,
                sortAscending: _sortAscending,
                sortColumnIndex: _sortColumnIndex,
                sortArrowIcon: Icons.keyboard_arrow_up,
                sortArrowAnimationDuration: const Duration(milliseconds: 500),
                border: TableBorder.all(color: Colors.grey[300]!),
                columns: [
                  const DataColumn2(
                    label: Text('Select'),
                    size: ColumnSize.S,
                    onSort: null,
                  ),
                  DataColumn2(
                    label: const Text('ID'),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) {
                      _sort<num>((product) => product.id, columnIndex, ascending);
                    },
                  ),
                  DataColumn2(
                    label: const Text('Title'),
                    size: ColumnSize.M,
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
                  const DataColumn2(
                    label: Text('Image'),
                    size: ColumnSize.M,
                  ),
                ],
                rows: products != null
                    ? products.map((product) {
                  return DataRow2(
                    cells: [
                      DataCell(
                        Checkbox(
                          value: _selectedRows.contains(product.id),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _selectedRows.add(product.id);
                              } else {
                                _selectedRows.remove(product.id);
                              }
                            });
                          },
                        ),
                      ),
                      DataCell(Text(product.id.toString())),
                      DataCell(Text(product.title)),
                      DataCell(Text('\$${product.price}')),
                      DataCell(
                        GestureDetector(
                          onTap: () => _showFullScreenImage(product.images!.first),
                          child: Image.network(
                            product.images!.first,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
          ),
          ElevatedButton(
            onPressed: () => productNotifier.refreshProducts(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}