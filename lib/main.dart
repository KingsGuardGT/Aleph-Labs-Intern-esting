import 'package:flutter/material.dart';
import 'package:my_project/notifiers/setup_get_it.dart';
import 'package:my_project/repositories/product_service.dart';
import 'models/product.dart';

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

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    _productsFuture = getIt<ProductService>().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
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
                return Column(
                  children: [
                    ListTile(
                      title: Text(product.title),
                      subtitle: Text('\$${product.price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.expand_more),
                        color: Colors.green,
                        onPressed: () {
                          setState(() {
                            _isExpanded[index] = !_isExpanded[index];
                          });
                        },
                      ),
                    ),
                    if (_isExpanded[index])
                      Container(
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
                      ),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _loadProducts();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}