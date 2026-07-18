class MenuVariant {
  final String size;
  final double price;
  final double costPrice;

  MenuVariant({
    required this.size,
    required this.price,
    this.costPrice = 0,
  });

  factory MenuVariant.fromMap(Map<String, dynamic> map) {
    return MenuVariant(
      size: map['size']?.toString() ?? '-',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'price': price,
      'costPrice': costPrice,
    };
  }

  MenuVariant copyWith({
    String? size,
    double? price,
    double? costPrice,
  }) {
    return MenuVariant(
      size: size ?? this.size,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
    );
  }

  bool get hasCostBasis => costPrice.isFinite && costPrice > 0;

  bool get isValid =>
      price.isFinite && price > 0 && costPrice.isFinite && costPrice >= 0;

  double get grossMargin => price - costPrice;

  double get marginPercentage {
    if (!price.isFinite || price <= 0) return 0;
    return grossMargin / price * 100;
  }
}
