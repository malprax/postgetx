import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/local_loyalty_repository.dart';

void main() {
  group('Feature: Customer tier follows lifetime eligible spending', () {
    late Directory directory;
    late Box<dynamic> box;
    late double lifetimeSpend;
    late LocalLoyaltyRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'loyalty-tier-repository-',
      );

      Hive.init(directory.path);

      box = await Hive.openBox<dynamic>(
        'loyalty-tier-${DateTime.now().microsecondsSinceEpoch}',
      );

      lifetimeSpend = 0;

      repository = LocalLoyaltyRepository(
        HiveLoyaltyProvider(box),
        actorId: () => 'bdd-owner',
        lifetimeEligibleSpend: (_) => lifetimeSpend,
      );
    });

    tearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    test(
      'Given a customer has Rp2.500.000 eligible lifetime spending, '
      'When the tier profile is requested, '
      'Then the customer is Silver with a bounded reward multiplier',
      () async {
        // Given:
        lifetimeSpend = 2500000;

        // When:
        final profile = await repository.getTierProfile(
          'customer-1',
        );

        // Then:
        expect(profile.customerId, 'customer-1');
        expect(profile.lifetimeEligibleSpend, 2500000);
        expect(profile.tier, LoyaltyTier.silver);
        expect(profile.pointsMultiplier, 1.25);
        expect(profile.rewardPoints(10), 12);
      },
    );

    test(
      'Given refunded spending no longer counts toward lifetime value, '
      'When eligible spending falls below Silver, '
      'Then the customer tier returns to Member',
      () async {
        // Given:
        lifetimeSpend = 1200000;
        final beforeRefund = await repository.getTierProfile(
          'customer-1',
        );

        // When:
        lifetimeSpend = 900000;
        final afterRefund = await repository.getTierProfile(
          'customer-1',
        );

        // Then:
        expect(beforeRefund.tier, LoyaltyTier.silver);
        expect(afterRefund.tier, LoyaltyTier.member);
        expect(afterRefund.pointsMultiplier, 1);
      },
    );

    test(
      'Given lifetime spending is invalid, '
      'When the tier profile is requested, '
      'Then safe Member defaults are returned',
      () async {
        // Given:
        lifetimeSpend = double.nan;

        // When:
        final profile = await repository.getTierProfile(
          'customer-1',
        );

        // Then:
        expect(profile.lifetimeEligibleSpend, 0);
        expect(profile.tier, LoyaltyTier.member);
        expect(profile.pointsMultiplier, 1);
      },
    );
  });
}
