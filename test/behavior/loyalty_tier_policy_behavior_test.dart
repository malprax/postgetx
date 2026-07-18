import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';

void main() {
  group('Feature: Customers advance through safe loyalty tiers', () {
    test(
      'Given a customer spends below the Silver threshold, '
      'When the loyalty tier is calculated, '
      'Then the customer remains a Member',
      () {
        // Given:
        const spending = 999999.0;

        // When:
        final tier = LoyaltyTierRules.defaults.resolve(spending);

        // Then:
        expect(tier, LoyaltyTier.member);
        expect(tier.label, 'Member');
      },
    );

    test(
      'Given a customer reaches Silver but not Gold spending, '
      'When the loyalty tier is calculated, '
      'Then the customer becomes Silver',
      () {
        // Given:
        const spending = 2500000.0;

        // When:
        final tier = LoyaltyTierRules.defaults.resolve(spending);

        // Then:
        expect(tier, LoyaltyTier.silver);
      },
    );

    test(
      'Given a customer reaches the Gold threshold, '
      'When the loyalty tier is calculated, '
      'Then the customer becomes Gold',
      () {
        // Given:
        const spending = 5000000.0;

        // When:
        final tier = LoyaltyTierRules.defaults.resolve(spending);

        // Then:
        expect(tier, LoyaltyTier.gold);
      },
    );

    test(
      'Given Silver and Gold receive bounded point multipliers, '
      'When base points are rewarded, '
      'Then benefits increase without exceeding the safety cap',
      () {
        // Given:
        const basePoints = 10;
        const rules = LoyaltyTierRules.defaults;

        // When:
        final member = rules.rewardedPoints(
          basePoints: basePoints,
          tier: LoyaltyTier.member,
        );

        final silver = rules.rewardedPoints(
          basePoints: basePoints,
          tier: LoyaltyTier.silver,
        );

        final gold = rules.rewardedPoints(
          basePoints: basePoints,
          tier: LoyaltyTier.gold,
        );

        // Then:
        expect(member, 10);
        expect(silver, 12);
        expect(gold, 15);
        expect(member, lessThanOrEqualTo(silver));
        expect(silver, lessThanOrEqualTo(gold));
      },
    );

    test(
      'Given unsafe thresholds or excessive rewards, '
      'When tier rules are validated, '
      'Then the configuration is rejected',
      () {
        // Given:
        const unsafe = LoyaltyTierRules(
          silverMinimumSpend: 5000000,
          goldMinimumSpend: 1000000,
          memberPointsMultiplier: 1,
          silverPointsMultiplier: 2.5,
          goldPointsMultiplier: 1.5,
        );

        // When:
        final errors = unsafe.validate();

        // Then:
        expect(errors, isNotEmpty);
        expect(
          errors.join(' '),
          contains('Gold minimum spending'),
        );
        expect(
          errors.join(' '),
          contains('between 1 and 2'),
        );
      },
    );
  });
}
