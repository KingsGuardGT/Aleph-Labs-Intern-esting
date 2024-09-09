// presentation/screens/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/presentation/widgets/products_list_floating_action_button.dart';
import '../../data/notifiers/product_notifier.dart';
import '../widgets/products_list_body.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const ProductListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(productNotifierProvider.notifier).refreshProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}