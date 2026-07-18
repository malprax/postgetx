import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/core/services/loyalty_points_policy.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';

void main() {
  group('Feature: Loyalty calculation follows owner configuration', () {
    test(
      'Given an owner requires Rp20.000 spending per point, '
      'When an eligible Rp50.000 transaction completes, '
      'Then the customer earns 2 points',
      () {
        // Given:
        final configuration = LoyaltyConfiguration.defaults.copyWith(
          spendPerPoint: 20000,
          minimumEligibleTransaction: 10000,
        );

        // When:
        final points = LoyaltyPointsPolicy.earnedPoints(
          50000,
          isEnabled: configuration.isEnabled,
          spendingRequired: configuration.spendPerPoint,
          minimumEligibleTransaction: configuration.minimumEligibleTransaction,
        );

        // Then:
        expect(points, 2);
      },
    );

    test(
      'Given a transaction is below the configured minimum, '
      'When earned points are calculated, '
      'Then no points are awarded',
      () {
        // Given:
        final configuration = LoyaltyConfiguration.defaults.copyWith(
          spendPerPoint: 10000,
          minimumEligibleTransaction: 50000,
        );

        // When:
        final points = LoyaltyPointsPolicy.earnedPoints(
          49999,
          isEnabled: configuration.isEnabled,
          spendingRequired: configuration.spendPerPoint,
          minimumEligibleTransaction: configuration.minimumEligibleTransaction,
        );

        // Then:
        expect(points, 0);
      },
    );

    test(
      'Given redemption is limited to 25 percent of a Rp40.000 payment, '
      'When the customer owns 200 points worth Rp100 each, '
      'Then at most 100 points may be redeemed',
      () {
        // Given:
        final configuration = LoyaltyConfiguration.defaults.copyWith(
          redeemValuePerPoint: 100,
          maximumRedemptionPercentage: 25,
        );

        // When:
        final maximumPoints = LoyaltyPointsPolicy.maximumRedeemablePoints(
          availablePoints: 200,
          payableAmount: 40000,
          valuePerPoint: configuration.redeemValuePerPoint,
          maximumRedemptionPercentage:
              configuration.maximumRedemptionPercentage,
          isEnabled: configuration.isEnabled,
        );

        // Then:
        expect(maximumPoints, 100);
        expect(
          LoyaltyPointsPolicy.redemptionValue(
            maximumPoints,
            valuePerPoint: configuration.redeemValuePerPoint,
          ),
          10000,
        );
      },
    );

    test(
      'Given loyalty is disabled, '
      'When earning and redemption are calculated, '
      'Then no points or discount are produced',
      () {
        // Given:
        final configuration = LoyaltyConfiguration.defaults.copyWith(
          isEnabled: false,
        );

        // When:
        final earned = LoyaltyPointsPolicy.earnedPoints(
          100000,
          isEnabled: configuration.isEnabled,
          spendingRequired: configuration.spendPerPoint,
        );

        final redeemed = LoyaltyPointsPolicy.redemptionValue(
          10,
          isEnabled: configuration.isEnabled,
          valuePerPoint: configuration.redeemValuePerPoint,
        );

        // Then:
        expect(earned, 0);
        expect(redeemed, 0);
      },
    );
  });
}
