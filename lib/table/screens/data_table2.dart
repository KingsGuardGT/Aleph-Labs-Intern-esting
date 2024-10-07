// lib/table/screens/data_table2.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';
import '../../main.dart';
import '../../presentation/states/table_state.dart';

class DataTable2Demo extends ConsumerStatefulWidget {
  const DataTable2Demo({super.key});

  @override
  DataTable2DemoState createState() => DataTable2DemoState();
}

class DataTable2DemoState extends ConsumerState<DataTable2Demo> {
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
    Future(() async {
      ref.read(tableNotifierProvider.notifier).updateIsLoading(true);
      final cachedProducts = await ref.read(tableNotifierProvider.notifier).getCachedData(
        ref.read(tableNotifierProvider).currentPage,
        ref.read(tableNotifierProvider).itemsPerPage,
      );
      if (cachedProducts.isNotEmpty) {
        ref.read(tableNotifierProvider.notifier).updateDisplayedProducts(cachedProducts);
        ref.read(tableNotifierProvider.notifier).updateIsLoading(false);
      } else {
        await _fetchAndCacheData();
      }
    });
  }

  Future<void> _loadMoreData() async {
    if (!ref.read(tableNotifierProvider).isLoading) {
      ref.read(tableNotifierProvider.notifier).updateIsLoading(true);
      ref.read(tableNotifierProvider.notifier).updateCurrentPage(
        ref.read(tableNotifierProvider).currentPage + 1,
      );
      await _fetchAndCacheData();
    }
  }

  Future<void> _fetchAndCacheData() async {
    final productNotifier = ref.read(productNotifierProvider);
    final newProducts = await productNotifier.fetchProducts(
      ref.read(tableNotifierProvider).currentPage,
      ref.read(tableNotifierProvider).itemsPerPage,
    );
    await ref.read(tableNotifierProvider.notifier).cacheData(newProducts, ref.read(tableNotifierProvider).currentPage);
    ref.read(tableNotifierProvider.notifier).updateDisplayedProducts(
      [...ref.read(tableNotifierProvider).displayedProducts, ...newProducts],
    );
    ref.read(tableNotifierProvider.notifier).updateIsLoading(false);
  }

  void _sort<T>(Comparable<T> Function(Product p) getField, bool ascending) {
    ref.read(tableNotifierProvider.notifier).updateSortAscending(ascending);
    final sortedProducts = [...ref.read(tableNotifierProvider).displayedProducts];
    sortedProducts.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    ref.read(tableNotifierProvider.notifier).updateDisplayedProducts(sortedProducts);
  }

  void _showFullScreenImage(String? imageUrl, ThemeData theme) {
    if (imageUrl != null) {
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
                  errorWidget: (context, error, stackTrace) => Text('Error loading image', style: theme.textTheme.bodyMedium),
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
    final searchQuery = ref.read(tableNotifierProvider).searchQuery;
    if (searchQuery.isEmpty) {
      return products;
    }
    return products.where((product) {
      final id = product.id.toString();
      final title = product.title.toLowerCase();
      final price = product.price.toString();
      return id.contains(searchQuery.toLowerCase()) ||
          title.contains(searchQuery.toLowerCase()) ||
          price.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final filteredProducts = _getFilteredProducts(ref.watch(tableNotifierProvider).displayedProducts);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            PopupMenuButton<int>(
              icon: Icon(Icons.sort, color: theme.colorScheme.onPrimary),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.sort_by_alpha, color: theme.colorScheme.onPrimary),
                        onPressed: () => _sort((p) => p.title, ref.read(tableNotifierProvider).sortAscending),
                        tooltip: 'Sort by Title',
                      ),
                      IconButton(
                        icon: Icon(Icons.sort, color: theme.colorScheme.onPrimary),
                        onPressed: () => _sort((p) => p.price, ref.read(tableNotifierProvider).sortAscending),
                        tooltip: 'Sort by Price',
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_upward, color: theme.colorScheme.onPrimary),
                        onPressed: () => _sort((p) => p.id, true),
                        tooltip: 'Sort by ID Ascending',
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward, color: theme.colorScheme.onPrimary),
                        onPressed: () => _sort((p) => p.id, false),
                        tooltip: 'Sort by ID Descending',
                      ),
                    ],
                  ),
                ),
              ],
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )
          ],
        ),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                    ),
                    onChanged: (query) {
                      ref.read(tableNotifierProvider.notifier).updateSearchQuery(query);
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
                        ref.read(tableNotifierProvider.notifier).updateSearchQuery('');
                      },
                      child: Text('Clear', style: theme.textTheme.bodyMedium),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(tableNotifierProvider.notifier).updateDisplayedProducts(
                          _getFilteredProducts(ref.read(tableNotifierProvider).displayedProducts),
                        );
                      },
                      child: Text('Search', style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ResponsiveUtils.isMobile(context)
          ? _buildMobileView(filteredProducts, theme)
          : _buildDataTable(filteredProducts, theme),
    );
  }

  Widget _buildMobileView(List<Product> products, ThemeData theme) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(product.title, style: theme.textTheme.titleMedium),
                subtitle: Text('ID: ${product.id}'),
                trailing: Text('Price: \$${product.price.toStringAsFixed(2)}'),
              ),
              ExpansionTile(
                title: const Text('More Details'),
                children: [
                  ListTile(
                    title: Text('Description: ${product.description ?? 'N/A'}'),
                  ),
                  ListTile(
                    title: Text('Created: ${product.creationAt != null ? DateFormat('yy-MM-dd').format(product.creationAt!) : 'N/A'}'),
                  ),
                  ListTile(
                    title: Text('Updated: ${product.updatedAt != null ? DateFormat('yy-MM-dd').format(product.updatedAt!) : 'N/A'}'),
                  ),
                  ListTile(
                    trailing: product.images != null && product.images!.isNotEmpty
                        ? GestureDetector(
                      onTap: () => _showFullScreenImage(product.images!.first, theme),
                      child: CachedNetworkImage(
                        imageUrl: product.images!.first,
                        errorWidget: (context, url, error) => Text('Error loading image', style: theme.textTheme.bodyMedium),
                        width: 120,
                        height: 200,
                        fit: BoxFit.fill,
                      ),
                    )
                        : Text('No image', style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<Product> products, ThemeData theme) {
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
                  return _buildDataRow(theme, product );
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
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onPrimary),
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
              onTap: () => _showFullScreenImage(product.images?.first, theme),
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