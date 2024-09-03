import 'package:flutter/material.dart';
import 'package:my_project/data/notifiers/setup_get_it.dart';
import 'package:my_project/data/repositories/product_service.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/pages/products_list_screen.dart';

void main() {
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProductListScreen(),
    );
  }
}
