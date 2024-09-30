import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';
import '../../main.dart';

class DataTable2Demo extends ConsumerStatefulWidget {
  const DataTable2Demo({super.key});

  @override
  DataTable2DemoState createState() => DataTable2DemoState();
}

class DataTable2DemoState extends ConsumerState<DataTable2Demo> {
  bool _sortAscending = true;
  int? _sortColumnIndex;

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

  void _showFullScreenImage(String? imageUrl) {
    if (imageUrl != null) {
      final theme = ref.watch(themeProvider);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Error loading image', style: theme.textTheme.bodyMedium);
                  },
                ),
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.sortedProducts.isNotEmpty
        ? productNotifier.sortedProducts
        : productNotifier.pagingController.itemList;

    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (productNotifier.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                productNotifier.errorMessage,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          Expanded(
            child: screenWidth > 600
                ? _buildDataTable(products, theme)
                : _buildListView(products, theme),
          ),
          ElevatedButton(
            onPressed: () => productNotifier.refreshProducts(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text('Refresh', style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Product>? products, ThemeData theme) {
    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onPrimary),
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(5),
        ),
      ),
      child: DataTable2(
        headingRowColor: WidgetStatePropertyAll(theme.colorScheme.primary),
        headingTextStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
        checkboxHorizontalMargin: 12,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: true,
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        sortArrowIcon: Icons.keyboard_arrow_up,
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        border: TableBorder.all(color: theme.dividerColor),
        columns: [
          DataColumn2(
            label: Text('ID', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary)),
            size: ColumnSize.S,
            fixedWidth: 60, // Compact fixed width for ID column
            onSort: (columnIndex, ascending) {
              _sort<num>((product) => product.id, columnIndex, ascending);
            },
          ),
          DataColumn2(
            label: Text('Title', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary)),
            size: ColumnSize.L,
            fixedWidth: 200,
            onSort: (columnIndex, ascending) {
              _sort<String>((product) => product.title, columnIndex, ascending);
            },
          ),
          DataColumn2(
            label: Text('Price', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary)),
            size: ColumnSize.S,
            fixedWidth: 100,
            onSort: (columnIndex, ascending) {
              _sort<num>((product) => product.price, columnIndex, ascending);
            },
          ),
          const DataColumn2(
            label: Text('Description'),
            size: ColumnSize.L,
          ),
          const DataColumn2(
            label: Text('Created'),
            size: ColumnSize.S,
            fixedWidth: 100,
          ),
          const DataColumn2(
            label: Text('Updated'),
            size: ColumnSize.S,
            fixedWidth: 100,
          ),
          const DataColumn2(
            label: Text('Image'),
            size: ColumnSize.M,
            fixedWidth: 200,
          ),
        ],
        rows: products != null
            ? products.map((product) {
          return DataRow2(
            cells: [
              DataCell(Center(child: Text(product.id.toString(), style: theme.textTheme.bodyMedium))),
              DataCell(Text(product.title, style: theme.textTheme.bodyMedium)),
              DataCell(Text('\$${product.price.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium)),
              DataCell(
                SizedBox(
                  width: 800,
                  height: 100,
                  child: Text(
                    product.description ?? 'N/A',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              DataCell(Text(product.creationAt != null
                  ? DateFormat('yy-MM-dd').format(product.creationAt!)
                  : 'N/A', style: theme.textTheme.bodyMedium)),
              DataCell(Text(product.updatedAt != null
                  ? DateFormat('yy-MM-dd').format(product.updatedAt!)
                  : 'N/A', style: theme.textTheme.bodyMedium)),
              DataCell(
                product.images != null && product.images!.isNotEmpty
                    ? GestureDetector(
                  onTap: () => _showFullScreenImage(product.images!.first),
                  child: Image.network(
                    product.images!.first,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading image', style: theme.textTheme.bodyMedium);
                    },
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
                    : Text('No image', style: theme.textTheme.bodyMedium),
              ),
            ],
          );
        }).toList()
            : [],
        empty: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.surface,
            child: Text('No data', style: theme.textTheme.bodyLarge),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<Product>? products, ThemeData theme) {
    return Theme(
      data: theme,
      child: ListView.builder(
        itemCount: products?.length ?? 0,
        itemBuilder: (context, index) {
          final product = products![index];
          return Theme(
            data: theme,
            child: ExpansionTile(
              title: Text(product.title, style: theme.textTheme.titleMedium),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
              children: [
                ListTile(
                  title: Text('Description', style: theme.textTheme.titleSmall),
                  subtitle: Text(product.description ?? 'N/A', style: theme.textTheme.bodyMedium),
                ),
                ListTile(
                  title: Text('Created At', style: theme.textTheme.titleSmall),
                  subtitle: Text(product.creationAt != null
                      ? DateFormat('yyyy-MM-dd').format(product.creationAt!)
                      : 'N/A', style: theme.textTheme.bodyMedium),
                ),
                ListTile(
                  title: Text('Updated At', style: theme.textTheme.titleSmall),
                  subtitle: Text(product.updatedAt != null
                      ? DateFormat('yyyy-MM-dd').format(product.updatedAt!)
                      : 'N/A', style: theme.textTheme.bodyMedium),
                ),
                if (product.images != null && product.images!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFullScreenImage(product.images!.first),
                    child : Image.network(
                      product.images!.first,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Error loading image', style: theme.textTheme.bodyMedium);
                      },
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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