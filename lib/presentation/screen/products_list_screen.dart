import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notifiers/product_notifier.dart';
import '../../data/notifiers/sidebar_controller_provider.dart';
import '../../main.dart';
import '../widgets/products_list_body.dart';
import '../widgets/products_sidebar.dart';  // Import the ExampleSidebarX widget

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void dispose() {
    ref.read(productNotifierProvider).pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality here
              },
            ),
          ),
        ],
      ),
      drawer: const ExampleSidebarX(),
      body: const Column(
        children: [
          Expanded(child: ProductListBody()),
        ],
      ),
    );
  }
}