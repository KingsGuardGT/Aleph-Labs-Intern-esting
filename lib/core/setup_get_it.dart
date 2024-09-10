// dio and repository provider setup

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/data/repositories/product_repository.dart';

// Provide a single instance of Dio
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Provide an instance of ProductRepository, using the Dio instance
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});
