import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';

void main() {
  group('Feature: Product cost basis protects restock capital', () {
    test(
      'Given a product has selling and cost prices, '
      'When its margin is calculated, '
      'Then cost and gross margin remain distinct',
      () {
        // Given:
        final variant = MenuVariant(
          size: 'Regular',
          price: 100000,
          costPrice: 60000,
        );

        // When:
        final restored = MenuVariant.fromMap(
          variant.toMap(),
        );

        // Then:
        expect(restored.price, 100000);
        expect(restored.costPrice, 60000);
        expect(restored.hasCostBasis, isTrue);
        expect(restored.grossMargin, 40000);
        expect(restored.marginPercentage, 40);
        expect(restored.isValid, isTrue);
      },
    );

    test(
      'Given a legacy product has no stored cost price, '
      'When it is restored, '
      'Then cost defaults to unknown without inventing margin data',
      () {
        // Given:
        final legacy = <String, dynamic>{
          'size': 'Regular',
          'price': 100000,
        };

        // When:
        final restored = MenuVariant.fromMap(legacy);

        // Then:
        expect(restored.costPrice, 0);
        expect(restored.hasCostBasis, isFalse);
        expect(restored.isValid, isTrue);
      },
    );

    test(
      'Given a product is sold below its cost, '
      'When margin is calculated, '
      'Then the loss remains visible instead of being hidden',
      () {
        // Given:
        final variant = MenuVariant(
          size: 'Regular',
          price: 50000,
          costPrice: 60000,
        );

        // When:
        final margin = variant.grossMargin;

        // Then:
        expect(margin, -10000);
        expect(variant.marginPercentage, -20);
        expect(variant.isValid, isTrue);
      },
    );

    test(
      'Given a negative or non-finite cost price, '
      'When the variant is validated, '
      'Then it is rejected before reaching capital calculations',
      () {
        // Given / When:
        final negative = MenuVariant(
          size: 'Regular',
          price: 50000,
          costPrice: -1,
        );

        final invalid = MenuVariant(
          size: 'Regular',
          price: 50000,
          costPrice: double.nan,
        );

        // Then:
        expect(negative.isValid, isFalse);
        expect(invalid.isValid, isFalse);
      },
    );
  });
}
