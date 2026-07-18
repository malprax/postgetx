class MenuVariant {
  final String size;
  final double price;

  MenuVariant({
    required this.size,
    required this.price,
  });

  factory MenuVariant.fromMap(Map<String, dynamic> map) {
    return MenuVariant(
      size: map['size']?.toString() ?? '-',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'price': price,
    };
  }

  MenuVariant copyWith({
    String? size,
    double? price,
  }) {
    return MenuVariant(
      size: size ?? this.size,
      price: price ?? this.price,
    );
  }
}
