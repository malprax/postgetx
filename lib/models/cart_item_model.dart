// lib/models/cart_item_model.dart
class CartItemModel {
  final String name;
  final String size;
  late final int quantity;
  final double price;
  final bool isExtra;

  CartItemModel({
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
    this.isExtra = false,
    required String id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'size': size,
      'quantity': quantity,
      'price': price,
      'isExtra': isExtra,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      name: map['name'],
      size: map['size'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
      isExtra: map['isExtra'] ?? false,
      id: '',
    );
  }

  get id => null;
}
