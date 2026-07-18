// lib/models/cart_item_model.dart
class CartItemModel {
  final String id; // ✅ tambahkan
  final String name;
  final String size; // ✅ tambahkan
  final double price;
  final double costPrice;
  int quantity;
  final bool isExtra;

  CartItemModel({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    this.costPrice = 0,
    required this.quantity,
    this.isExtra = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'isExtra': isExtra,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      isExtra: map['isExtra'] ?? false,
    );
  }

  bool get hasCostBasis => costPrice.isFinite && costPrice > 0;

  double get lineRevenue => price * quantity;

  double get lineCost => costPrice * quantity;

  double get lineGrossMargin => lineRevenue - lineCost;

  CartItemModel copyWith({
    String? id,
    String? name,
    String? size,
    double? price,
    double? costPrice,
    int? quantity,
    bool? isExtra,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      isExtra: isExtra ?? this.isExtra,
    );
  }
}
