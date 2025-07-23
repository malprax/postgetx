import 'package:postgetx/models/cart_item_model.dart';

class OrderModel {
  final String? id; // optional ID Firestore
  final List<CartItemModel> items;
  final double total;
  final double discount;
  final double paid;
  final double change;
  final String createdBy;
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.items,
    required this.total,
    required this.discount,
    required this.paid,
    required this.change,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'discount': discount,
        'paid': paid,
        'change': change,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderModel(
      id: id,
      items: (map['items'] as List)
          .map((e) => CartItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      paid: (map['paid'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
