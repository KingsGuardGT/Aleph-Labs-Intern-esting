import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';

class PaginatedDataTableDemo extends ConsumerStatefulWidget {
  const PaginatedDataTableDemo({super.key});

  @override
  PaginatedDataTableDemoState createState() => PaginatedDataTableDemoState();
}

class PaginatedDataTableDemoState extends ConsumerState<PaginatedDataTableDemo> with RestorationMixin {
  final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage);
  final RestorableInt _sortColumnIndex = RestorableInt(0);
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableInt _rowIndex = RestorableInt(0);
  late ProductDataSource _productDataSource;

  @override
  String get restorationId => 'combined_data_table_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_rowIndex, 'current_row_index');
  }

  @override
  void initState() {
    super.initState();
    _productDataSource = ProductDataSource(
      onShowFullScreenImage: _showFullScreenImage,
    );
  }

  void _sort<T>(Comparable<T> Function(Product p) getField, int columnIndex, bool ascending) {
    _productDataSource.sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex.value = columnIndex;
      _sortAscending.value = ascending;
    });
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
    _productDataSource.updateProducts(productNotifier.pagingController.itemList ?? []);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 8),
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
                  child: SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: Text(
                        'Product Table',
                        style: TextStyle(fontSize: isTablet ? 18 : 14),
                      ),
                      rowsPerPage: _rowsPerPage.value,
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          _rowsPerPage.value = value!;
                        });
                      },
                      availableRowsPerPage: const [5, 10, 20],
                      initialFirstRowIndex: _rowIndex.value,
                      onPageChanged: (rowIndex) {
                        setState(() {
                          _rowIndex.value = rowIndex;
                        });
                      },
                      sortColumnIndex: _sortColumnIndex.value,
                      sortAscending: _sortAscending.value,
                      onSelectAll: _productDataSource.selectAll,
                      columns: [
                        DataColumn(
                          label: Text(
                            'ID',
                            style: TextStyle(fontSize: isTablet ? 16 : 12),
                          ),
                          onSort: (columnIndex, ascending) {
                            _sort<num>((product) => product.id, columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: Text(
                            'Title',
                            style: TextStyle(fontSize: isTablet ? 16 : 12),
                          ),
                          onSort: (columnIndex, ascending) {
                            _sort<String>((product) => product.title, columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: Text(
                            'Price',
                            style: TextStyle(fontSize: isTablet ? 16 : 12),
                          ),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            _sort<num>((product) => product.price, columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: Text(
                            'Image',
                            style: TextStyle(fontSize: isTablet ? 16 : 12),
                          ),
                        ),
                      ],
                      source: _productDataSource,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () => productNotifier.refreshProducts(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(isTablet ? 120 : 80, 40),
                    ),
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductDataSource extends DataTableSource {
  List<Product> _products = [];
  Set<int> _selectedProducts = {};
  final Function(String) onShowFullScreenImage;

  ProductDataSource({required this.onShowFullScreenImage});

  void updateProducts(List<Product> newProducts) {
    _products = newProducts;
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(Product p) getField, bool ascending) {
    _products.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final product = _products[index];
    return DataRow(
      cells: [
        DataCell(Text(product.id.toString())),
        DataCell(Text(product.title)),
        DataCell(Text('\$${product.price}')),
        DataCell(
          GestureDetector(
            onTap: () => onShowFullScreenImage(_getValidImageUrl(product.images?.first)),
            child: _buildProductImage(_getValidImageUrl(product.images?.first)),
          ),
        ),
      ],
      selected: _selectedProducts.contains(product.id),
      onSelectChanged: (selected) {
        if (selected != null) {
          _onSelectedChanged(product.id, selected);
        }
      },
    );
  }

  String _getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/150'; // Placeholder image URL
    }
    // Remove square brackets if present
    return url.replaceAll(RegExp(r'[\[\]]'), '');
  }

  Widget _buildProductImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, size: 50);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _onSelectedChanged(int id, bool selected) {
    if (selected) {
      _selectedProducts.add(id);
    } else {
      _selectedProducts.remove(id);
    }
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _products.length;

  @override
  int get selectedRowCount => _selectedProducts.length;

  void selectAll(bool? allSelected) {
    if (allSelected == null) return;
    _selectedProducts.clear();
    if (allSelected) {
      _selectedProducts.addAll(_products.map((p) => p.id));
    }
    notifyListeners();
  }
}