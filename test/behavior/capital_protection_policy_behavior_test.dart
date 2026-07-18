import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';
import 'package:postgetx/app/modules/capital/domain/capital_protection_policy.dart';

void main() {
  group('Feature: Sales money is separated before owner consumption', () {
    test(
      'Given an item costs Rp60.000 and sells for Rp100.000, '
      'When capital protection allocates the sale, '
      'Then restock capital is protected before margin is available',
      () {
        // Given:
        const revenue = 100000.0;
        const cost = 60000.0;

        // When:
        final allocation = CapitalProtectionPolicy.allocate(
          salesRevenue: revenue,
          costBasis: cost,
        );

        // Then:
        expect(allocation.restockRequirement, 60000);
        expect(allocation.protectedCapital, 60000);
        expect(allocation.grossMargin, 40000);
        expect(allocation.operationalReserve, 8000);
        expect(allocation.safeToUse, 32000);
        expect(allocation.capitalDeficit, 0);
        expect(allocation.allocatedCash, revenue);
        expect(allocation.capitalIsSafe, isTrue);
      },
    );

    test(
      'Given a sale occurs below its cost basis, '
      'When capital protection allocates the money, '
      'Then all received cash is protected and the deficit is visible',
      () {
        // Given:
        const revenue = 50000.0;
        const cost = 60000.0;

        // When:
        final allocation = CapitalProtectionPolicy.allocate(
          salesRevenue: revenue,
          costBasis: cost,
        );

        // Then:
        expect(allocation.protectedCapital, 50000);
        expect(allocation.grossMargin, -10000);
        expect(allocation.operationalReserve, 0);
        expect(allocation.safeToUse, 0);
        expect(allocation.capitalDeficit, 10000);
        expect(allocation.capitalIsSafe, isFalse);
      },
    );

    test(
      'Given an owner requires a minimum cash buffer, '
      'When positive margin is allocated, '
      'Then the buffer reduces money declared safe to consume',
      () {
        // Given:
        const configuration = CapitalProtectionConfiguration(
          operationalReservePercentage: 20,
          minimumCashBuffer: 10000,
        );

        // When:
        final allocation = CapitalProtectionPolicy.allocate(
          salesRevenue: 100000,
          costBasis: 60000,
          configuration: configuration,
        );

        // Then:
        expect(allocation.operationalReserve, 8000);
        expect(allocation.minimumCashBuffer, 10000);
        expect(allocation.safeToUse, 22000);
      },
    );

    test(
      'Given unsafe reserve configuration or invalid money values, '
      'When allocation is requested, '
      'Then calculation is rejected before business data changes',
      () {
        // Given:
        const unsafeConfiguration = CapitalProtectionConfiguration(
          operationalReservePercentage: 90,
          minimumCashBuffer: -1,
        );

        // When / Then:
        expect(
          () => CapitalProtectionPolicy.allocate(
            salesRevenue: 100000,
            costBasis: 60000,
            configuration: unsafeConfiguration,
          ),
          throwsA(isA<FormatException>()),
        );

        expect(
          () => CapitalProtectionPolicy.allocate(
            salesRevenue: double.nan,
            costBasis: 60000,
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
