// domain/entities/product.dart

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String createdAt;
  final String updatedAt;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
  });
}