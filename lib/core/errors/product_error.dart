// core/error/errors/product_error.dart

class ProductError implements Error {
  final String message;

  ProductError(this.message);

  @override
  // TODO: implement stackTrace
  StackTrace? get stackTrace => throw UnimplementedError();
}