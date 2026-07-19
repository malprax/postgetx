import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/shared/widgets/product_pricing_fields.dart';

void main() {
  testWidgets(
    'Given a presentational product pricing form, '
    'When selling and cost prices are entered, '
    'Then both values remain available without storage or GetX',
    (tester) async {
      // Given:
      final selling = TextEditingController();
      final cost = TextEditingController();

      addTearDown(() {
        selling.dispose();
        cost.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: ProductPricingFields(
                sellingPriceController: selling,
                costPriceController: cost,
              ),
            ),
          ),
        ),
      );

      // When:
      await tester.enterText(
        find.byKey(const ValueKey('product-selling-price')),
        '100000',
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-cost-price')),
        '60000',
      );

      // Then:
      expect(selling.text, '100000');
      expect(cost.text, '60000');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given a product pricing form, '
    'When cost price is empty or zero, '
    'Then validation blocks an unknown replacement cost',
    (tester) async {
      // Given:
      final selling = TextEditingController(text: '100000');
      final cost = TextEditingController(text: '0');
      final formKey = GlobalKey<FormState>();

      addTearDown(() {
        selling.dispose();
        cost.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: ProductPricingFields(
                sellingPriceController: selling,
                costPriceController: cost,
              ),
            ),
          ),
        ),
      );

      // When:
      final valid = formKey.currentState!.validate();
      await tester.pump();

      // Then:
      expect(valid, isFalse);
      expect(
        find.textContaining('Cost price'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
