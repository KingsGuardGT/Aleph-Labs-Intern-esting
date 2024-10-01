// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';
import '../../main.dart';
import '../custom_pager.dart';
import '../helper.dart';
import '../nav_helper.dart';

class AsyncPaginatedDataTable2Demo extends ConsumerStatefulWidget {
  const AsyncPaginatedDataTable2Demo({super.key});

  @override
  AsyncPaginatedDataTable2DemoState createState() =>
      AsyncPaginatedDataTable2DemoState();
}

class AsyncPaginatedDataTable2DemoState
    extends ConsumerState<AsyncPaginatedDataTable2Demo> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  bool _sortAscending = true;
  int? _sortColumnIndex;
  final PaginatorController _controller = PaginatorController();

  bool _dataSourceLoading = false;
  int _initialRow = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // For any async data fetching or state change, delay the state update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming you have a method to get the total number of records
      // if (getCurrentRouteOption(context) == goToLast) {
      //   _dataSourceLoading = true;
      //   productNotifier.getTotalRecords().then((count) {
      //     setState(() {
      //       _initialRow = count - _rowsPerPage;
      //       _dataSourceLoading = false;
      //     });
      //   });
      // }
    });
  }


  void sort<T>(
      Comparable<T> Function(Product p) getField,
      int columnIndex,
      bool ascending,
      ) {
    final productNotifier = ref.read(productNotifierProvider);

    // Perform sorting
    productNotifier.sortProducts((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });

    // Postpone the call to setState to avoid calling it during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sortColumnIndex = columnIndex;
        _sortAscending = ascending;
      });
    });
  }


  @override
  void dispose() {
    final productNotifier = ref.read(productNotifierProvider);
    productNotifier.dispose();
    super.dispose();
  }

  List<DataColumn> get _columns {
    return [
      DataColumn(
        label: const Text('Title'),
        onSort: (columnIndex, ascending) => sort<String>((p) => p.title, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Price'),
        numeric: true,
        onSort: (columnIndex, ascending) => sort<num>((p) => p.price, columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Description'),
        onSort: (columnIndex, ascending) => sort<String?>((p) => p.description ?? '', columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Created At'),
        onSort: (columnIndex, ascending) => sort<DateTime?>((p) => p.creationAt ?? DateTime(1970), columnIndex, ascending),
      ),
      DataColumn(
        label: const Text('Updated At'),
        onSort: (columnIndex, ascending) => sort<DateTime?>((p) => p.updatedAt ?? DateTime(1970), columnIndex, ascending),
      ),
      const DataColumn(
        label: Text('Image'),
      ),
    ];
  }

  // Use global key to avoid rebuilding state of _TitledRangeSelector
  // upon AsyncPaginatedDataTable2 refreshes, e.g. upon page switches
  final GlobalKey _rangeSelectorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final productNotifier = ref.watch(productNotifierProvider);
    final products = productNotifier.sortedProducts.isNotEmpty
        ? productNotifier.sortedProducts
        : productNotifier.pagingController.itemList ?? [];

    if (_dataSourceLoading) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 100, // You can adjust this to a suitable value
              maxHeight: constraints.maxHeight, // Keep the maximum constraint
            ),
            child: Column(
              children: [
                Flexible(
                  child: AsyncPaginatedDataTable2(
                    horizontalMargin: 20,
                    checkboxHorizontalMargin: 12,
                    columnSpacing: 0,
                    wrapInCard: false,
                    header: SizedBox(
                      height: 100, // Adjust this value as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: _TitledRangeSelector(
                              range: const RangeValues(150, 600),
                              onChanged: (v) {
                                // Your onChanged logic
                              },
                              key: _rangeSelectorKey,
                              title: 'AsyncPaginatedDataTable2',
                              caption: 'Price',
                            ),
                          ),
                          if (kDebugMode &&
                              getCurrentRouteOption(context) == custPager)
                            Row(children: [
                              OutlinedButton(
                                onPressed: () => _controller.goToPageWithRow(25),
                                child: const Text('Go to row 25'),
                              ),
                              OutlinedButton(
                                onPressed: () => _controller.goToRow(5),
                                child: const Text('Go to row 5'),
                              )
                            ]),
                          if (getCurrentRouteOption(context) == custPager)
                            PageNumber(controller: _controller)
                        ],
                      ),
                    ),
                    rowsPerPage: _rowsPerPage,
                    autoRowsToHeight: getCurrentRouteOption(context) == autoRows,
                    pageSyncApproach:
                    getCurrentRouteOption(context) == dflt
                        ? PageSyncApproach.doNothing
                        : getCurrentRouteOption(context) == autoRows
                        ? PageSyncApproach.goToLast
                        : PageSyncApproach.goToFirst,
                    minWidth: 800,
                    fit: FlexFit.tight,
                    border: TableBorder(
                      top: BorderSide(color: theme.colorScheme.primary),
                      bottom: BorderSide(color: theme.colorScheme.surface),
                      left: BorderSide(color: theme.colorScheme.surface),
                      right: BorderSide(color: theme.colorScheme.surface),
                      verticalInside: BorderSide(color: theme.colorScheme.surface),
                      horizontalInside:
                      BorderSide(color: theme.colorScheme.surface),
                    ),
                    onRowsPerPageChanged: (value) {
                      print('Row per page changed to $value');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _rowsPerPage = value!;
                        });
                      });
                    },

                    initialFirstRowIndex: _initialRow,
                    onPageChanged: (rowIndex) {
                      //print(rowIndex / _rowsPerPage);
                    },
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    sortArrowIcon: Icons.keyboard_arrow_up,
                    sortArrowAnimationDuration:
                    const Duration(milliseconds: 0),
                    onSelectAll: (select) => select != null && select
                        ? (getCurrentRouteOption(context) != selectAllPage
                        ? null
                        : null)
                        : (getCurrentRouteOption(context) != selectAllPage
                        ? null
                        : null),
                    controller: _controller,
                    hidePaginator:
                    getCurrentRouteOption(context) == custPager,
                    columns: _columns,
                    empty: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: theme.colorScheme.surface,
                        child: Text('No data',
                            style: theme.textTheme.bodyLarge),
                      ),
                    ),
                    loading: _Loading(),
                    errorBuilder: (e) => _ErrorAndRetry(
                        e.toString(), () => productNotifier.refreshProducts()),
                    source: _ProductAsyncDataSource(products, context),
                  ),
                ),
                if (getCurrentRouteOption(context) == custPager)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomPager(_controller),
                  ),
              ],
            ),
          ),
        );
      },
    );

  }
}

class _ErrorAndRetry extends StatelessWidget {
  const _ErrorAndRetry(this.errorMessage, this.retry);

  final String errorMessage;
  final void Function() retry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 70,
        color: theme.colorScheme.error,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Oops! $errorMessage',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onError)),
            TextButton(
              onPressed: retry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    color: theme.colorScheme.onError,
                  ),
                  Text('Retry', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onError))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Loading extends StatefulWidget {
  @override
  __LoadingState createState() => __LoadingState();
}

class __LoadingState extends State<_Loading> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface.withAlpha(128),
      // at first show shade, if loading takes longer than 0,5s show spinner
      child: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 500), () => true ),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? const SizedBox()
              : Center(
              child : Container(
                color: theme.colorScheme.primary,
                padding: const EdgeInsets.all(7),
                width: 150,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                    Text('Loading..', style: theme.textTheme.bodyMedium)
                  ],
                ),
              ));
        },
      ),
    );
  }
}

class _TitledRangeSelector extends StatefulWidget {
  const _TitledRangeSelector(
      {super.key,
        required this.onChanged,
        this.title = "",
        this.caption = "",
        this.range = const RangeValues(0, 100)});

  final String title;
  final String caption;
  final Duration titleToSelectorSwitch = const Duration(seconds: 2);
  final RangeValues range;
  final Function(RangeValues) onChanged;

  @override
  State<_TitledRangeSelector> createState() => _TitledRangeSelectorState();
}

class _TitledRangeSelectorState extends State<_TitledRangeSelector> {
  bool _titleVisible = true;
  RangeValues _values = const RangeValues(0, 100);

  @override
  void initState() {
    super.initState();

    _values = widget.range;

    Timer(widget.titleToSelectorSwitch, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _titleVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(alignment: Alignment.centerLeft, children: [
      AnimatedOpacity(
        opacity: _titleVisible ? 1 : 0,
        duration: const Duration(milliseconds: 1000),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.title, style: theme.textTheme.titleMedium),
        ),
      ),
      AnimatedOpacity(
        opacity: _titleVisible ? 0 : 1,
        duration: const Duration(milliseconds: 1000),
        child: SizedBox(
          width: 340,
          child: Theme(
            data: blackSlider(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _values.start.toStringAsFixed(0),
                        ),
                        Text(
                          widget.caption,
                        ),
                        Text(
                          _values.end.toStringAsFixed(0),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: RangeSlider(
                    values: _values,
                    divisions: 9,
                    min: widget.range.start,
                    max: widget.range.end,
                    onChanged: (v) {
                      setState(() {
                        _values = v;
                      });
                      widget.onChanged(v);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }
}

class _ProductAsyncDataSource extends AsyncDataTableSource {
  final List<Product> _products;
  final BuildContext context;

  _ProductAsyncDataSource(this._products, this.context);

  void _showFullScreenImage(String? imageUrl) {
    if (imageUrl != null) {
      final theme = Theme.of(context);
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
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    final endIndex = startIndex + count;
    final rows = _products
        .sublist(startIndex, endIndex > _products.length ? _products.length : endIndex)
        .asMap()
        .entries
        .map((entry) {
      final product = entry.value;
      return DataRow.byIndex(
        index: startIndex + entry.key,
        cells: [
          DataCell(Text(product.title)),
          DataCell(Text(product.price.toString())),
          DataCell(Text(product.description ?? '')),
          DataCell(Text(DateFormat('yyyy-MM-dd').format(product.creationAt ?? DateTime(1970)))),
          DataCell(Text(DateFormat('yyyy-MM-dd').format(product.updatedAt ?? DateTime(1970)))),
          DataCell(
            product.images != null && product.images!.isNotEmpty
                ? GestureDetector(
              onTap: () => _showFullScreenImage(product.images!.first),
              child: Image.network(
                product.images!.first,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error loading image');
                },
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
                : const Text('No image'),
          ),
        ],
      );
    }).toList();

    return AsyncRowsResponse(
      rows.length,
      rows,
    );
  }

  @override
  int get rowCount => _products.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}