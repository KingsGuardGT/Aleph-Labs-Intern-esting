import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _searchQuery = '';
  Set<int> _selectedRows = {};
  List<Product> _displayedProducts = [];
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    final cachedProducts = await _getCachedData(_currentPage, _itemsPerPage);
    if (cachedProducts.isNotEmpty) {
      setState(() {
        _displayedProducts = cachedProducts;
        _isLoading = false;
      });
    } else {
      await _fetchAndCacheData();
    }
  }

  Future<void> _loadMoreData() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _currentPage++;
      });
      await _fetchAndCacheData();
    }
  }

  Future<void> _fetchAndCacheData() async {
    final productNotifier = ref.read(productNotifierProvider);
    final newProducts = await productNotifier.fetchProducts(_currentPage, _itemsPerPage);
    await _cacheData(newProducts, _currentPage);
    setState(() {
      _displayedProducts.addAll(newProducts);
      _isLoading = false;
    });
  }

  Future<void> _cacheData(List<Product> products, int page) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = await compute(_encodeProducts, products);
    await prefs.setString('cached_products_page_$page', jsonString);
  }

  static String _encodeProducts(List<Product> products) {
    return jsonEncode(products.map((product) => product.toJson()).toList());
  }

  Future<List<Product>> _getCachedData(int page, int itemsPerPage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cached_products_page_$page');
    if (jsonString != null) {
      final List<dynamic> jsonData = await compute(_decodeJson, jsonString);
      return jsonData.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  static List<dynamic> _decodeJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  void _sort<T>(
      Comparable<T> Function(Product p) getField,
      int columnIndex,
      bool ascending,
      ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _displayedProducts.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
      });
    });
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
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  errorWidget: (context, error, stackTrace) {
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

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) =>
    product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (product.description != null && product.description!.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.pagingController.itemList ?? [];

    final filteredProducts = _getFilteredProducts(products);
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              productNotifier.pagingController.refresh(); // Refresh the paging controller on search
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: screenWidth > 600
                ? _buildDataTable(filteredProducts, theme)
                : _buildListView(filteredProducts, theme),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ElevatedButton(
            onPressed: () async {
              productNotifier.clearCache();
              productNotifier.pagingController.refresh(); // Re-fetch the data and clear cache
            },
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

  Widget _buildDataTable(List<Product> products, ThemeData theme) {
    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(color: theme.colorScheme.onPrimary),
        scrollbarTheme: const ScrollbarThemeData(
          thickness: WidgetStatePropertyAll(5),
        ),
      ),
      child: DataTable2(
        scrollController: _scrollController,
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
        rows: products.asMap().entries.map((entry) {
          final product = entry.value;
          final isSelected = _selectedRows.contains(entry.key);
          return DataRow2(
            onSelectChanged: (isSelected) {
              setState(() {
                if (isSelected ?? false) {
                  _selectedRows.add(entry.key);
                } else {
                  _selectedRows.remove(entry.key);
                }
              });
            },
            selected: isSelected,
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
                  child: CachedNetworkImage(
                    imageUrl: product.images!.first,
                    errorWidget: (context, url, error) => Text('Error loading image', style: theme.textTheme.bodyMedium),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
                    : Text('No image', style: theme.textTheme.bodyMedium),
              ),
            ],
          );
        }).toList(),
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

  Widget _buildListView(List<Product> products, ThemeData theme) {
    return Theme(
      data: theme,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: products.length + 1, // +1 for the loading indicator
        itemBuilder: (context, index) {
          if (index == products.length) {
            return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
          }
          final product = products[index];
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
                    child: CachedNetworkImage(
                      imageUrl: product.images!.first,
                      errorWidget: (context, error, stackTrace) {
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
