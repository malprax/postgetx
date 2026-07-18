import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/models/cart_item_model.dart';
import 'package:postgetx/models/order_model.dart';

void main() {
  test('local transaction round-trips without cloud timestamp types', () {
    final createdAt = DateTime(2026, 7, 16, 10, 30);
    final order = OrderModel(
      id: 'local-1',
      orderId: 'DEMO-1',
      items: [
        CartItemModel(
          id: 'cola',
          name: 'Cola',
          size: 'Regular',
          price: 12500,
          quantity: 2,
        ),
      ],
      totalAmount: 25000,
      discount: 10,
      paid: 25000,
      change: 2500,
      createdAt: createdAt,
      createdBy: 'demo-admin',
    );
    final restored = OrderModel.fromMap(
      order.id,
      {...order.toMap(), 'createdAt': createdAt.toIso8601String()},
    );
    expect(restored.createdAt, createdAt);
    expect(restored.items.single.quantity, 2);
    expect(restored.discount, 10);
  });
}
