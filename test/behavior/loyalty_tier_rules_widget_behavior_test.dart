import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/modules/settings/widgets/loyalty_tier_rules_form.dart';

void main() {
  testWidgets(
    'Given a presentational tier form, '
    'When safe owner rules are submitted, '
    'Then the callback receives validated values without storage access',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Given:
      LoyaltyTierRules? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoyaltyTierRulesForm(
              initialRules: LoyaltyTierRules.defaults,
              onSave: (rules) async {
                submitted = rules;
                return null;
              },
            ),
          ),
        ),
      );

      // When:
      await tester.enterText(
        find.byKey(const ValueKey('tier-silver-spend')),
        '2000000',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tier-gold-spend')),
        '8000000',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tier-member-multiplier')),
        '1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tier-silver-multiplier')),
        '1.2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tier-gold-multiplier')),
        '1.6',
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('save-tier-rules')),
      );

      await tester.pump();
      await tester.pump();

      // Then:
      expect(submitted, isNotNull);
      expect(submitted?.silverMinimumSpend, 2000000);
      expect(submitted?.goldMinimumSpend, 8000000);
      expect(submitted?.silverPointsMultiplier, 1.2);
      expect(submitted?.goldPointsMultiplier, 1.6);
      expect(find.text('Tier rules saved.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given a presentational tier form, '
    'When an excessive reward multiplier is submitted, '
    'Then validation rejects it before invoking the callback',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Given:
      var callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoyaltyTierRulesForm(
              initialRules: LoyaltyTierRules.defaults,
              onSave: (_) async {
                callbackCount++;
                return null;
              },
            ),
          ),
        ),
      );

      // When:
      await tester.enterText(
        find.byKey(const ValueKey('tier-gold-multiplier')),
        '3',
      );

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey('save-tier-rules')),
      );

      await tester.pump();

      // Then:
      expect(callbackCount, 0);
      expect(
        find.text('Multiplier must be between 1 and 2.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
