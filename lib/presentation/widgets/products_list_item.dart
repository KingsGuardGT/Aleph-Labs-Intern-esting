import 'package:flutter/material.dart';
import 'package:my_project/data/models/product.dart';
import 'package:my_project/presentation/widgets/products_list_expanded_item.dart';

class ProductListItem extends StatefulWidget {
  final Product product;

  const ProductListItem({super.key, required this.product});

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
            onPressed: toggleExpanded,
          ),
        ),
        if (isExpanded)
          ProductListExpandedItem(product: widget.product),
      ],
    );
  }
}