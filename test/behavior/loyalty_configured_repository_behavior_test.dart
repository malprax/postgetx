import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/local_loyalty_repository.dart';

void main() {
  group('Feature: Loyalty repository follows live configuration', () {
    late Directory directory;
    late Box<dynamic> box;
    late LoyaltyConfiguration configuration;
    late LocalLoyaltyRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'configured-loyalty-repository-',
      );

      Hive.init(directory.path);

      box = await Hive.openBox<dynamic>(
        'configured-loyalty-${DateTime.now().microsecondsSinceEpoch}',
      );

      configuration = LoyaltyConfiguration.defaults;

      repository = LocalLoyaltyRepository(
        HiveLoyaltyProvider(box),
        actorId: () => 'bdd-owner',
        configuration: () => configuration,
      );
    });

    tearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    test(
      'Given the owner changes spending required per point, '
      'When the next transaction earns loyalty, '
      'Then the new configuration is used immediately',
      () async {
        // Given:
        configuration = configuration.copyWith(
          spendPerPoint: 20000,
          minimumEligibleTransaction: 50000,
        );

        // When:
        final result = await repository.earnForOrder(
          customerId: 'customer-1',
          orderId: 'configured-order-1',
          eligibleAmount: 90000,
        );

        // Then:
        expect(result.isSuccess, isTrue);
        expect(result.value?.pointsDelta, 4);
        expect(await repository.getBalance('customer-1'), 4);
      },
    );

    test(
      'Given loyalty is disabled, '
      'When a transaction attempts to earn points, '
      'Then no ledger entry is created',
      () async {
        // Given:
        configuration = configuration.copyWith(isEnabled: false);

        // When:
        final result = await repository.earnForOrder(
          customerId: 'customer-1',
          orderId: 'configured-order-disabled',
          eligibleAmount: 100000,
        );

        // Then:
        expect(result.isSuccess, isFalse);
        expect(result.code, 'no_loyalty_points');
        expect(await repository.getLedger(), isEmpty);
      },
    );
  });
}
