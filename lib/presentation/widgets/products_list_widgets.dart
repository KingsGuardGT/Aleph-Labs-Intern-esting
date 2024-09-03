import 'package:flutter/material.dart';

import '../../data/models/product.dart';

class ProductListBody extends StatefulWidget {
  final Future<List<Product>> productsFuture;
  final Function toggleExpanded;

  const ProductListBody({super.key, 
    required this.productsFuture,
    required this.toggleExpanded, required List<bool> isExpanded,
  });

  @override
  _ProductListBodyState createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<ProductListBody> {
  List<bool> _isExpanded = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: widget.productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        } else {
          final products = snapshot.data!;
          if (_isExpanded.length != products.length) {
            _isExpanded = List<bool>.filled(products.length, false);
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListItem(
                product: product,
                isExpanded: _isExpanded[index],
                toggleExpanded: () => widget.toggleExpanded(index),
                onExpansionChanged: (bool value) {
                  setState(() {
                    _isExpanded[index] = value;
                  });
                },
              );
            },
          );
        }
      },
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;
  final bool isExpanded;
  final Function toggleExpanded;
  final Function onExpansionChanged;

  const ProductListItem({super.key, 
    required this.product,
    required this.isExpanded,
    required this.toggleExpanded,
    required this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(product.title),
          subtitle: Text('\$${product.price}'),
          trailing: IconButton(
            icon: const Icon(Icons.expand_more),
            color: Colors.green,
            onPressed: () {
              toggleExpanded();
              onExpansionChanged(!isExpanded);
            },
          ),
        ),
        if (isExpanded)
          ProductListExpandedItem(product: product),
      ],
    );
  }
}

class ProductListExpandedItem extends StatelessWidget {
  final Product product;

  const ProductListExpandedItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description: ${product.description}'),
          const SizedBox(height: 8),
          Text('Created At: ${product.createdAt}'),
          const SizedBox(height: 8),
          Text('Updated At: ${product.updatedAt}'),
          const SizedBox(height: 16),
          if (product.images != null)
            Column(
              children: product.images!.map((image) {
                String imageUrl = image.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Image.network(
                    imageUrl,
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

class ProductListFloatingActionButton extends StatelessWidget {
  final Function onPressed;

  const ProductListFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => onPressed(),
      child: const Icon(Icons.refresh),
    );
  }
}