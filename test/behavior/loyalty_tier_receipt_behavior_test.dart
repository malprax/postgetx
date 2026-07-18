import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/core/services/pdf_helper.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';

void main() {
  group('Feature: Receipt preserves the tier used by a transaction', () {
    test(
      'Given a sale earned points as a Gold customer, '
      'When order data is serialized and restored, '
      'Then its Gold tier and multiplier remain unchanged',
      () {
        // Given:
        final order = OrderModel(
          id: 'tier-receipt-order',
          orderId: 'TIER-RECEIPT-ORDER',
          items: [
            CartItemModel(
              id: 'product-1',
              name: 'Tier Product',
              size: 'Regular',
              price: 100000,
              quantity: 1,
            ),
          ],
          totalAmount: 100000,
          discount: 0,
          loyaltyPointsEarned: 15,
          loyaltyBalanceAfter: 35,
          loyaltyTier: 'gold',
          loyaltyPointsMultiplier: 1.5,
          paid: 100000,
          change: 0,
          createdAt: DateTime(2026, 7, 19),
          createdBy: 'bdd-owner',
          customerId: 'customer-gold',
          customerName: 'Gold Customer',
        );

        // When:
        final restored = OrderModel.fromMap(
          order.id,
          order.toMap(),
        );

        final receipt = ReceiptData.fromOrder(restored);

        // Then:
        expect(restored.loyaltyTier, 'gold');
        expect(restored.loyaltyPointsMultiplier, 1.5);
        expect(restored.loyaltyPointsEarned, 15);
        expect(receipt.loyaltyTier, 'gold');
        expect(receipt.loyaltyPointsMultiplier, 1.5);
      },
    );

    test(
      'Given tier rules change after an old sale, '
      'When the old receipt is generated, '
      'Then its original tier snapshot is still printable',
      () async {
        // Given:
        final historicalOrder = OrderModel(
          id: 'historical-silver-order',
          orderId: 'HISTORICAL-SILVER',
          items: [
            CartItemModel(
              id: 'product-1',
              name: 'Historical Product',
              size: 'Regular',
              price: 50000,
              quantity: 1,
            ),
          ],
          totalAmount: 50000,
          discount: 0,
          loyaltyPointsEarned: 6,
          loyaltyBalanceAfter: 16,
          loyaltyTier: 'silver',
          loyaltyPointsMultiplier: 1.25,
          paid: 50000,
          change: 0,
          createdAt: DateTime(2026, 7, 19),
          createdBy: 'bdd-owner',
          customerId: 'customer-silver',
          customerName: 'Silver Customer',
        );

        // When:
        final pdf = await PdfHelper.generatePdfNota(
          historicalOrder,
        );

        final bytes = await pdf.save();

        // Then:
        final receipt = ReceiptData.fromOrder(historicalOrder);
        expect(receipt.loyaltyTier, 'silver');
        expect(receipt.loyaltyPointsMultiplier, 1.25);
        expect(bytes, isNotEmpty);
      },
    );

    test(
      'Given a legacy order has no tier snapshot, '
      'When it is restored, '
      'Then safe Member defaults preserve compatibility',
      () {
        // Given:
        final legacyMap = <String, dynamic>{
          'orderId': 'LEGACY-ORDER',
          'items': <dynamic>[],
          'totalAmount': 0,
          'discount': 0,
          'paid': 0,
          'change': 0,
          'createdAt': DateTime(2026, 7, 19).toIso8601String(),
          'createdBy': 'legacy-owner',
        };

        // When:
        final restored = OrderModel.fromMap(
          'legacy-order',
          legacyMap,
        );

        // Then:
        expect(restored.loyaltyTier, 'member');
        expect(restored.loyaltyPointsMultiplier, 1);
      },
    );
  });
}
