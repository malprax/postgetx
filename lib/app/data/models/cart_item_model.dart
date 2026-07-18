// lib/models/cart_item_model.dart
class CartItemModel {
  final String id; // ✅ tambahkan
  final String name;
  final String size; // ✅ tambahkan
  final double price;
  int quantity;
  final bool isExtra;

  CartItemModel({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.quantity,
    this.isExtra = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'price': price,
      'quantity': quantity,
      'isExtra': isExtra,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      size: map['size'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
      isExtra: map['isExtra'] ?? false,
    );
  }
}
