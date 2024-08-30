import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:my_project/repositories/product_repository.dart';
import 'package:my_project/repositories/product_service.dart';

final GetIt getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ProductRepository>(() => ProductRepository(getIt<Dio>()));
  getIt.registerLazySingleton<ProductService>(() => ProductService(getIt<ProductRepository>()));
}