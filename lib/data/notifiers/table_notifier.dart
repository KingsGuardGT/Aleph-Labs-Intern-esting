
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/product.dart';

final tableCacheNotifierProvider = Provider<TableCacheNotifier>((ref) {
  return TableCacheNotifier();
});

class TableCacheNotifier {
  Future<void> cacheData(List<Product> products, int page) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = await compute(_encodeProducts, products);
    await prefs.setString('cached_products_page_$page', jsonString);
  }

  static String _encodeProducts(List<Product> products) {
    return jsonEncode(products.map((product) => product.toJson()).toList());
  }

  Future<List<Product>> getCachedData(int page, int itemsPerPage) async {
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
}