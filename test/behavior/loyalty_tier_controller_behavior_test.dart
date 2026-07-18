import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/modules/settings/controllers/loyalty_tier_rules_controller.dart';

void main() {
  group('Feature: Owner controls loyalty tier rules', () {
    test(
      'Given saved rules exist in offline storage, '
      'When the controller loads, '
      'Then the same rules are applied to checkout',
      () {
        // Given:
        const stored = LoyaltyTierRules(
          silverMinimumSpend: 2000000,
          goldMinimumSpend: 7000000,
          memberPointsMultiplier: 1,
          silverPointsMultiplier: 1.2,
          goldPointsMultiplier: 1.6,
        );

        LoyaltyTierRules? applied;

        final controller = LoyaltyTierRulesController(
          readRules: () => stored,
          writeRules: (_) async {},
          applyRules: (rules) => applied = rules,
          canManage: () => true,
        );

        // When:
        controller.load();

        // Then:
        expect(controller.rules.value.toMap(), stored.toMap());
        expect(applied?.toMap(), stored.toMap());
      },
    );

    test(
      'Given a staff user attempts to change tier benefits, '
      'When save is requested, '
      'Then the change is rejected before persistence',
      () async {
        // Given:
        var writeCount = 0;
        var applyCount = 0;

        final controller = LoyaltyTierRulesController(
          readRules: () => LoyaltyTierRules.defaults,
          writeRules: (_) async => writeCount++,
          applyRules: (_) => applyCount++,
          canManage: () => false,
        );

        // When:
        final saved = await controller.save(
          LoyaltyTierRules.defaults,
        );

        // Then:
        expect(saved, isFalse);
        expect(writeCount, 0);
        expect(applyCount, 0);
        expect(
          controller.errorMessage.value,
          contains('Only an owner'),
        );
      },
    );

    test(
      'Given an owner submits valid safe tier rules, '
      'When save succeeds, '
      'Then persistence and active checkout rules update together',
      () async {
        // Given:
        const updated = LoyaltyTierRules(
          silverMinimumSpend: 3000000,
          goldMinimumSpend: 9000000,
          memberPointsMultiplier: 1,
          silverPointsMultiplier: 1.3,
          goldPointsMultiplier: 1.7,
        );

        LoyaltyTierRules? written;
        LoyaltyTierRules? applied;

        final controller = LoyaltyTierRulesController(
          readRules: () => LoyaltyTierRules.defaults,
          writeRules: (rules) async => written = rules,
          applyRules: (rules) => applied = rules,
          canManage: () => true,
        );

        // When:
        final saved = await controller.save(updated);

        // Then:
        expect(saved, isTrue);
        expect(written?.toMap(), updated.toMap());
        expect(applied?.toMap(), updated.toMap());
        expect(controller.rules.value.toMap(), updated.toMap());
        expect(controller.saving.value, isFalse);
      },
    );
  });
}
