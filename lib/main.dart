import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:my_project/repositories/image_repository.dart';
import 'package:my_project/notifiers/image_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_project/notifiers/setup_get_it.dart';
import 'package:my_project/repositories/product_service.dart';
import 'package:my_project/models/product.dart';

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

// Create a Screen to Display Products
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
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
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.title),
                  subtitle: Text('\$${product.price}'),
                  onTap: () {
                    // Handle product tap
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _productsFuture = getIt<ProductService>().getProducts();
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