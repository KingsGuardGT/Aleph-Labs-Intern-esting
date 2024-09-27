import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/models/product.dart';

class ProductListExpandedItem extends ConsumerWidget {
  final Product product;

  const ProductListExpandedItem({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

            Column(
              children: product.images!.map((image) {
                String imageUrl = image.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(
                    'https://picsum.photos/250?image=9',
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Failed to load image');
                    },
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}