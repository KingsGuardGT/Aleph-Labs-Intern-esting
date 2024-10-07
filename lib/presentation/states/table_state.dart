// lib/presentation/states/table_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/data/notifiers/table_notifier.dart';

class TableState {
  final bool sortAscending;
  final String searchQuery;
  final List<Product> displayedProducts;
  final int currentPage;
  final int itemsPerPage;
  final bool isLoading;

  TableState({
    this.sortAscending = true,
    this.searchQuery = '',
    this.displayedProducts = const [],
    this.currentPage = 1,
    this.itemsPerPage = 20,
    this.isLoading = false,
  });

  TableState copyWith({
    bool? sortAscending,
    String? searchQuery,
    List<Product>? displayedProducts,
    int? currentPage,
    int? itemsPerPage,
    bool? isLoading,
  }) {
    return TableState(
      sortAscending: sortAscending ?? this.sortAscending,
      searchQuery: searchQuery ?? this.searchQuery,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TableNotifier extends StateNotifier<TableState> {
  final TableCacheNotifier _tableCacheNotifier;

  TableNotifier(this._tableCacheNotifier) : super(TableState());

  void updateSortAscending(bool value) {
    state = state.copyWith(sortAscending: value);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateDisplayedProducts(List<Product> products) {
    state = state.copyWith(displayedProducts: products);
  }

  void updateCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void updateIsLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<List<Product>> getCachedData(int page, int itemsPerPage) async {
    return await _tableCacheNotifier.getCachedData(page, itemsPerPage);
  }

  Future<void> cacheData(List<Product> products, int page) async {
    await _tableCacheNotifier.cacheData(products, page);
  }
}

final tableNotifierProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  return TableNotifier(ref.watch(tableCacheNotifierProvider));
});