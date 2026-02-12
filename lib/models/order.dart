class Order {
  final String type;
  final List<String> items;
  final double totalAmount;
  final String paymentMethod;

  Order({
    required this.type,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });
}