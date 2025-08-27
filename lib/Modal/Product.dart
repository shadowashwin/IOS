class Product {
  const Product({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discountLabel,
    required this.badgeLeft,
    required this.badgeRight,
  });

  final String title;
  final double price;
  final double originalPrice;
  final String discountLabel;
  final String badgeLeft;
  final String badgeRight;

  bool get hasDiscount => originalPrice > price;
}
