import 'package:flutter/material.dart';

import '../../data/models/product.dart';

class ProductListBody extends StatefulWidget {
  final Future<List<Product>> products;

  const ProductListBody({super.key, 
    required this.products,
  });

  @override
  _ProductListBodyState createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<ProductListBody> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: widget.products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found.'));
        } else {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductListItem(
                product: product,
              );
            },
          );
        }
      },
    );
  }
}

class ProductListItem extends StatefulWidget {
  final Product product;

  const ProductListItem({super.key,
    required this.product,

  });

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

  class _ProductListItemState extends State<ProductListItem> {
  bool isExpanded = false;
  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.product.title),
          subtitle: Text('\$${widget.product.price}'),
          trailing: IconButton(
            icon: const Icon(Icons.expand_more),
            color: Colors.green,
            onPressed: () {
              toggleExpanded();
            },
          ),
        ),
        if (isExpanded)
          ProductListExpandedItem(product: widget.product),
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