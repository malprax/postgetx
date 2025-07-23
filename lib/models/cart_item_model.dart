class CartItemModel {
  final String? id; // optional ID
  final String name;
  final String size;
  int quantity;
  final double price;

  CartItemModel({
    this.id,
    required this.name,
    required this.size,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'size': size,
        'quantity': quantity,
        'price': price,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
