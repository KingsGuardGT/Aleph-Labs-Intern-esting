import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _searchQuery = '';
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
      bool ascending,
      ) {
    setState(() {
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
    if (_searchQuery.isEmpty) {
      return products;
    }
    return products.where((product) {
      final title = product.title.toLowerCase();
      final description = product.description?.toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) || description.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredProducts = _getFilteredProducts(_displayedProducts);
    return Scaffold(
      appBar: AppBar(
        title: Text('DataTable Demo', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Search', style: theme.textTheme.titleMedium),
                  content: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: theme.textTheme.bodyMedium),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Text('Clear', style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Sorting Dropdown
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButton<String>(
              value: null,  // Initial value (null for default "Sort by")
              hint: const Text('Sort by'),
              onChanged: (value) {
                switch (value) {
                  case 'ID (Low to High)':
                    _sort<num>((product) => product.id, true);
                    break;
                  case 'Title (A-Z)':
                    _sort<String>((product) => product.title, true);
                    break;
                  case 'Price (Low to High)':
                    _sort<num>((product) => product.price, true);
                    break;
                  case 'Date (Newest First)':
                    _sort<DateTime>((product) => product.creationAt ?? DateTime.now(), false);
                    break;
                }
              },
              items: [
                'ID (Low to High)',
                'Title (A-Z)',
                'Price (Low to High)',
                'Date (Newest First)',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _buildDataTable(filteredProducts, theme, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Product> products, ThemeData theme, double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDataTableHeader(theme),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildDataRow(theme, product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTableHeader(ThemeData theme) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.9),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'ID',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Title',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Price',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme .onPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Created',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Updated',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Image',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(ThemeData theme, Product product) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              product.id.toString(),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              product.title,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              product.description ?? 'N/A',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              product.creationAt != null ? DateFormat('yy-MM-dd').format(product.creationAt!) : 'N/A',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              product.updatedAt != null ? DateFormat('yy-MM-dd').format(product.updatedAt!) : 'N/A',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _showFullScreenImage(product.images?.first),
              child: product.images != null && product.images!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: product.images!.first,
                errorWidget: (context, url, error) => Text('Error loading image', style: theme.textTheme.bodyMedium),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
                  : Text('No image', style: theme.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}