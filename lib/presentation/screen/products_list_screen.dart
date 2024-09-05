import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/setup_get_it.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/products_list_widgets.dart';
import 'products_list_screen_state.dart';
import '../../data/models/product.dart';
import '../../data/notifiers/product_notifier.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products = getIt<ProductService>().getProducts();


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    // setState(() async {
    //   _products = getIt<ProductService>().getProducts();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ProductListBody(
        products: _products,
      ),
      floatingActionButton: ProductListFloatingActionButton(
        onPressed: _loadProducts,
      ),
    );
  }
}