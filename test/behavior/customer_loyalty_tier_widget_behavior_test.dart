import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/modules/customers/widgets/customer_loyalty_tier_summary.dart';

void main() {
  testWidgets(
    'Given a Gold customer profile, '
    'When the tier summary is displayed, '
    'Then tier spending and multiplier are visible',
    (tester) async {
      // Given:
      const profile = CustomerLoyaltyTierProfile(
        customerId: 'customer-gold',
        lifetimeEligibleSpend: 7500000,
        tier: LoyaltyTier.gold,
        pointsMultiplier: 1.5,
      );

      // When:
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomerLoyaltyTierSummary(
              profile: profile,
            ),
          ),
        ),
      );

      // Then:
      expect(find.text('Gold Customer'), findsOneWidget);
      expect(find.textContaining('Rp7.500.000'), findsOneWidget);
      expect(find.text('Points multiplier: x1.5'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey(
            'customer-tier-summary-customer-gold',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given a Silver customer appears in the directory, '
    'When the compact tier summary is displayed, '
    'Then a Silver badge is shown without storage access',
    (tester) async {
      // Given:
      const profile = CustomerLoyaltyTierProfile(
        customerId: 'customer-silver',
        lifetimeEligibleSpend: 2500000,
        tier: LoyaltyTier.silver,
        pointsMultiplier: 1.25,
      );

      // When:
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomerLoyaltyTierSummary(
              profile: profile,
              compact: true,
            ),
          ),
        ),
      );

      // Then:
      expect(find.text('Silver'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('customer-tier-customer-silver'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
