import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:my_project/data/repositories/product_repository.dart';
import 'package:my_project/data/notifiers/product_notifier.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

