import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/product_repository.dart';
import '../widgets/products_list_widgets.dart';
import 'products_list_screen_state.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ProductListState {
  final ProductService _productService = ProductService(ProductRepository(Dio()));
  final List<bool> _isExpanded = List<bool>.filled(6, false);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    // implement your product loading logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ProductListBody(
        productsFuture: _productService.getProducts(),
        toggleExpanded: (index) => setState(() {
          _isExpanded[index] = !_isExpanded[index];
        }), isExpanded: [],
      ),
      floatingActionButton: ProductListFloatingActionButton(
        onPressed: _loadProducts,
      ),
    );
  }
}