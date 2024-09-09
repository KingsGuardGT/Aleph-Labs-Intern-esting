// import 'package:flutter/material.dart';
// import 'package:my_project/presentation/screen/products_list_screen.dart';
// import 'package:my_project/presentation/widgets/products_list_floating_action_button.dart';
//
// import '../../data/models/product.dart';
// import '../../data/notifiers/setup_get_it.dart';
// import '../../data/repositories/product_notifier.dart';
//
// class ProductListState extends State<ProductListScreen> {
//   late Future<List<Product>> _productsFuture;
//   final List<bool> _isExpanded = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProducts();
//   }
//
//   Future<void> _loadProducts() async {
//     _productsFuture = getIt<ProductService>().getProducts();
//   }
//
//   void _toggleExpanded(int index) {
//     setState(() {
//       _isExpanded[index] = !_isExpanded[index];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ProductListBody(
//       products: _productsFuture,
//       isExpanded: _isExpanded,
//       toggleExpanded: _toggleExpanded,
//     );
//   }
// }