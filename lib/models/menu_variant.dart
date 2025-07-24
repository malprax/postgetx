class MenuVariant {
  final String size; // S, M, L, XL
  final int price;

  MenuVariant({
    required this.size,
    required this.price,
  });

  factory MenuVariant.fromMap(Map<String, dynamic> map) {
    return MenuVariant(
      size: map['size'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'price': price,
    };
  }
}
