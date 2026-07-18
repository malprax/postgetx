import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/core/services/loyalty_points_policy.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_model.dart';

void main() {
  group('Feature: Loyalty points reduce checkout total', () {
    test(
      'Given a Rp50.000 cart and Rp5.000 promotion, '
      'When 20 points are redeemed, '
      'Then Rp2.000 loyalty discount is applied before tax',
      () {
        // Given:
        final items = <CartItemModel>[
          CartItemModel(
            id: 'product-1',
            name: 'BDD Product',
            size: 'Regular',
            price: 25000,
            quantity: 2,
          ),
        ];

        final loyaltyDiscount = LoyaltyPointsPolicy.redemptionValue(20);

        // When:
        final totals = const PosTotalCalculator().calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 5000,
          loyaltyDiscount: loyaltyDiscount,
          taxType: TaxType.percentage,
          taxValue: 10,
        );

        // Then:
        expect(totals.subtotal, 50000);
        expect(totals.discountAmount, 5000);
        expect(totals.loyaltyDiscount, 2000);
        expect(totals.taxableAmount, 43000);
        expect(totals.taxAmount, 4300);
        expect(totals.total, 47300);
      },
    );

    test(
      'Given loyalty discount exceeds the payable amount, '
      'When totals are calculated, '
      'Then the discount is capped and total never becomes negative',
      () {
        // Given:
        final items = <CartItemModel>[
          CartItemModel(
            id: 'product-1',
            name: 'BDD Product',
            size: 'Regular',
            price: 10000,
            quantity: 1,
          ),
        ];

        // When:
        final totals = const PosTotalCalculator().calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 2000,
          loyaltyDiscount: 50000,
          taxType: TaxType.none,
          taxValue: 0,
        );

        // Then:
        expect(totals.discountAmount, 2000);
        expect(totals.loyaltyDiscount, 8000);
        expect(totals.taxableAmount, 0);
        expect(totals.total, 0);
      },
    );
  });

  group('Feature: Loyalty checkout data survives persistence', () {
    test(
      'Given an order uses loyalty points, '
      'When the order is serialized and restored, '
      'Then points and discount remain unchanged',
      () {
        // Given:
        final order = OrderModel(
          id: 'bdd-loyalty-order',
          orderId: 'BDD-LOYALTY-ORDER',
          items: [
            CartItemModel(
              id: 'product-1',
              name: 'BDD Product',
              size: 'Regular',
              price: 25000,
              quantity: 2,
            ),
          ],
          totalAmount: 47300,
          subtotal: 50000,
          discount: 5000,
          discountValue: 5000,
          loyaltyPointsRedeemed: 20,
          loyaltyDiscount: 2000,
          taxableAmount: 43000,
          taxType: TaxType.percentage,
          taxValue: 10,
          taxAmount: 4300,
          paid: 50000,
          change: 2700,
          createdAt: DateTime(2026, 7, 18),
          createdBy: 'bdd-owner',
          customerId: 'customer-1',
        );

        // When:
        final restored = OrderModel.fromMap(
          order.id,
          order.toMap(),
        );

        // Then:
        expect(restored.loyaltyPointsRedeemed, 20);
        expect(restored.loyaltyDiscount, 2000);
        expect(restored.taxableAmount, 43000);
        expect(restored.totalAmount, 47300);
      },
    );
  });
}
