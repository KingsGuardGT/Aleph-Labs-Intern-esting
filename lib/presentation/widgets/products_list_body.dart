import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_item.dart';

import '../../data/notifiers/product_notifier.dart';

class ProductListBody extends ConsumerStatefulWidget {
  const ProductListBody({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends ConsumerState<ProductListBody> {
  @override
  void initState() {
    super.initState();
    // Triggering the initial product list fetch when the widget is created.
    ref.read(productNotifierProvider.notifier).loadProducts();
  }
  @override
  Widget build(BuildContext context) {
    // Watching the product list async state.
    final products = ref.watch(productNotifierProvider.select((state) => state));

    return ListView.builder(
        itemCount: products.length,
        //scrollcontroller TODO
        itemBuilder: (context, index) {
          final product = products[index];

          return ProductListItem(
            product: product,
            index: index,
          );
        });
  }
}