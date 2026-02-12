class OrderResult {
  final bool success;
  final String message;

  OrderResult.success(this.message) : success = true;
  OrderResult.failure(this.message) : success = false;
}