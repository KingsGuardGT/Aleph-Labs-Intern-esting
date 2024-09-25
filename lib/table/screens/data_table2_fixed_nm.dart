import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';

class DataTable2FixedNMDemo extends ConsumerStatefulWidget {
  const DataTable2FixedNMDemo({super.key});

  @override
  DataTable2DemoState createState() => DataTable2DemoState();
}

class DataTable2DemoState extends ConsumerState<DataTable2FixedNMDemo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;
  int _fixedRows = 1;
  int _fixedCols = 1;
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
    final products = productNotifier.pagingController.itemList;

    return Scaffold(
        appBar: AppBar(
        title: const Text('Product Table'),
    ),
                  body: LayoutBuilder(
                  builder: (context, constraints) {
                  final isWeb = constraints.maxWidth > 600;

                  return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  if (isWeb) _buildWebSliders() else _buildMobileSliders(),
                  const SizedBox(height: 16),
                  Expanded(
                  child: Theme(
                  data: ThemeData(
                  iconTheme: const IconThemeData(color: Colors.white),
                  scrollbarTheme: ScrollbarThemeData(
                  thickness: WidgetStateProperty.all(5),
                  ),
                  ),
                  child: DataTable2(
                    headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[850]!),
                    headingTextStyle: const TextStyle(color: Colors.white),
                    checkboxHorizontalMargin: 12,
                    isHorizontalScrollBarVisible: true,
                    isVerticalScrollBarVisible: true,
                    columnSpacing: isWeb ? 12 : 8,
                    horizontalMargin: isWeb ? 12 : 8,
                    sortAscending: _sortAscending,
                    sortColumnIndex: _sortColumnIndex,
                    sortArrowIcon: Icons.keyboard_arrow_up,
                    sortArrowAnimationDuration: const Duration(milliseconds: 500),
                    border: TableBorder.all(color: Colors.grey[300]!),
                    fixedTopRows: _fixedRows,
                    fixedLeftColumns: _fixedCols,
                    columns: [
                      DataColumn2(
                        label: const Text('Select'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) => null,
                      ),
                      DataColumn2(
                        label: const Text('ID'),
                        size: isWeb ? ColumnSize.S : ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          _sort<num>((product) => product.id, columnIndex, ascending);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Title'),
                        size: isWeb ? ColumnSize.M : ColumnSize.L,
                        onSort: (columnIndex, ascending) {
                          _sort<String>((product) => product.title, columnIndex, ascending);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Price'),
                        size: isWeb ? ColumnSize.S : ColumnSize.M,
                        numeric: true,
                        onSort: (columnIndex, ascending) {
                          _sort<num>((product) => product.price, columnIndex, ascending);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Image'),
                        size: isWeb ? ColumnSize.M : ColumnSize.L,
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
                              onTap: () {
                                try {
                                  _showFullScreenImage(product.images!.first);
                                } catch (e) {
                                  if (kDebugMode) {
                                    print('Error loading image: $e');
                                  }
                                }
                              },
                              child: Image.network(
                                product.images!.first,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('Error loading image');
                                },
                              ),
                            ),
                          )
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
            ],
          ),
        );
      },
    ));
  }
  Widget _buildWebSliders() {
    return Row(
      children: [
        Expanded(child: _buildSlider('Fixed rows:', _fixedRows, 10, (value) => setState(() => _fixedRows = value))),
        const SizedBox(width: 16),
        Expanded(child: _buildSlider('Fixed columns:', _fixedCols, 2, (value) => setState(() => _fixedCols = value))),
      ],
    );
  }

  Widget _buildMobileSliders() {
    return Column(
      children: [
        _buildSlider('Fixed rows:', _fixedRows, 10, (value) => setState(() => _fixedRows = value)),
        const SizedBox(height: 8),
        _buildSlider('Fixed columns:', _fixedCols, 2, (value) => setState(() => _fixedCols = value)),
      ],
    );
  }

  Widget _buildSlider(String label, int value, double max, Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(width: 130, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: max,
            divisions: max.toInt(),
            label: value.toString(),
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ),
        Text('$value'),
      ],
    );
  }
}