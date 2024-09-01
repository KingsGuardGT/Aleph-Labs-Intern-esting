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
// final getIt = GetIt.instance;
//
// void setup() {
//   getIt.registerLazySingleton<ImageRepository>(() => ImageRepository());
//   getIt.registerSingleton<ImageNotifier>(ImageNotifier(getIt<ImageRepository>()));
// }
//
// class ImageScroll extends StatelessWidget {
//   const ImageScroll({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final imageNotifier = getIt<ImageNotifier>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image Scroll Project (ALL LENNOX)'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Expanded(
//               child: ValueListenableBuilder<int>(
//                 valueListenable: imageNotifier,
//                 builder: (context, imageIndex, child) {
//                   return Image.asset(
//                     imageNotifier.images[imageIndex].path,
//                     fit: BoxFit.contain,
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     imageNotifier.previousImage();
//                   },
//                   child: const Text('Previous'),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     imageNotifier.nextImage();
//                   },
//                   child: const Text('Next'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void main() {
//   setup();
//   runApp(
//     const MaterialApp(
//       home: ImageScroll(),
//     ),
//   );
// }