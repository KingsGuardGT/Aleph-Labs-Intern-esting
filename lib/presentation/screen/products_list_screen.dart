import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/widgets/products_list_widgets.dart';
import '../../data/notifiers/product_notifier.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listProduct = ref.watch(productNotifierProvider);



    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const ProductListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(productNotifierProvider.notifier).loadProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}