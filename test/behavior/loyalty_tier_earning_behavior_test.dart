import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/local_loyalty_repository.dart';

void main() {
  group('Feature: Loyalty tier increases earned points safely', () {
    late Directory directory;
    late Box<dynamic> box;
    late double lifetimeSpend;
    late LocalLoyaltyRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'loyalty-tier-earning-',
      );

      Hive.init(directory.path);

      box = await Hive.openBox<dynamic>(
        'loyalty-tier-earning-${DateTime.now().microsecondsSinceEpoch}',
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
      'Given a Silver customer earns 10 base points, '
      'When the completed sale is recorded, '
      'Then 12 bounded tier points enter the ledger',
      () async {
        // Given:
        lifetimeSpend = LoyaltyTierRules.defaults.silverMinimumSpend;

        // When:
        final result = await repository.earnForOrder(
          customerId: 'customer-silver',
          orderId: 'silver-order',
          eligibleAmount: 100000,
        );

        // Then:
        expect(result.isSuccess, isTrue);
        expect(result.value?.pointsDelta, 12);
        expect(
          await repository.getBalance('customer-silver'),
          12,
        );
      },
    );

    test(
      'Given a Gold customer earns 10 base points, '
      'When the completed sale is recorded twice, '
      'Then 15 points are awarded exactly once',
      () async {
        // Given:
        lifetimeSpend = LoyaltyTierRules.defaults.goldMinimumSpend;

        // When:
        final first = await repository.earnForOrder(
          customerId: 'customer-gold',
          orderId: 'gold-order',
          eligibleAmount: 100000,
        );

        final repeated = await repository.earnForOrder(
          customerId: 'customer-gold',
          orderId: 'gold-order',
          eligibleAmount: 100000,
        );

        // Then:
        expect(first.value?.pointsDelta, 15);
        expect(repeated.isIdempotent, isTrue);
        expect(
          await repository.getBalance('customer-gold'),
          15,
        );

        final ledger = await repository.getLedger(
          customerId: 'customer-gold',
        );

        expect(ledger, hasLength(1));
      },
    );

    test(
      'Given a Member customer earns base points, '
      'When the sale is recorded, '
      'Then no artificial bonus is added',
      () async {
        // Given:
        lifetimeSpend = 0;

        // When:
        final result = await repository.earnForOrder(
          customerId: 'customer-member',
          orderId: 'member-order',
          eligibleAmount: 100000,
        );

        // Then:
        expect(result.value?.pointsDelta, 10);
      },
    );
  });
}
