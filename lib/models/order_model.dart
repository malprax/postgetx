import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final double discount;
  final double paid;
  final double change;
  final Timestamp createdAt;
  final String createdBy;

  OrderModel({
    required this.id,
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.discount,
    required this.paid,
    required this.change,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'paid': paid,
      'change': change,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      orderId: map['orderId'] ?? '',
      items: (map['items'] as List)
          .map((e) => CartItemModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      paid: (map['paid'] ?? 0).toDouble(),
      change: (map['change'] ?? 0).toDouble(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
