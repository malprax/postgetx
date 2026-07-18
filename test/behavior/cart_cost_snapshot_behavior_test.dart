import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';

void main() {
  group('Feature: A sale preserves its original product cost', () {
    test(
      'Given a cart item has selling and cost prices, '
      'When it is serialized into an order and restored, '
      'Then historical revenue cost and margin remain unchanged',
      () {
        // Given:
        final item = CartItemModel(
          id: 'product-1',
          name: 'Protected Product',
          size: 'Regular',
          price: 100000,
          costPrice: 60000,
          quantity: 2,
        );

        // When:
        final restored = CartItemModel.fromMap(
          item.toMap(),
        );

        // Then:
        expect(restored.price, 100000);
        expect(restored.costPrice, 60000);
        expect(restored.quantity, 2);
        expect(restored.lineRevenue, 200000);
        expect(restored.lineCost, 120000);
        expect(restored.lineGrossMargin, 80000);
        expect(restored.hasCostBasis, isTrue);
      },
    );

    test(
      'Given a product cost changes after an old sale, '
      'When the old order item is copied for reporting, '
      'Then its original cost snapshot is retained',
      () {
        // Given:
        final historical = CartItemModel(
          id: 'product-1',
          name: 'Historical Product',
          size: 'Regular',
          price: 100000,
          costPrice: 60000,
          quantity: 1,
        );

        // When:
        final reportCopy = historical.copyWith(quantity: 2);

        // Then:
        expect(reportCopy.costPrice, 60000);
        expect(reportCopy.lineCost, 120000);
        expect(reportCopy.lineGrossMargin, 80000);
      },
    );

    test(
      'Given a legacy order item has no cost snapshot, '
      'When it is restored, '
      'Then cost remains unknown instead of being invented',
      () {
        // Given:
        final legacy = <String, dynamic>{
          'id': 'legacy-product',
          'name': 'Legacy Product',
          'size': 'Regular',
          'price': 50000,
          'quantity': 1,
        };

        // When:
        final restored = CartItemModel.fromMap(legacy);

        // Then:
        expect(restored.costPrice, 0);
        expect(restored.hasCostBasis, isFalse);
        expect(restored.lineCost, 0);
      },
    );
  });
}
