import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/local_loyalty_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalLoyaltyRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'bdd-order-redemption-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-order-redemption-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalLoyaltyRepository(
      HiveLoyaltyProvider(box),
      actorId: () => 'bdd-owner',
    );

    await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'earning-source',
      eligibleAmount: 50000,
    );
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  group('Feature: Checkout redemption follows order lifecycle', () {
    test(
      'Given a customer has 5 points, '
      'When checkout redeems 3 points twice for the same order, '
      'Then only one redemption is recorded',
      () async {
        // Given:
        expect(await repository.getBalance('customer-1'), 5);

        // When:
        final first = await repository.redeemForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-checkout-order',
          points: 3,
          reason: 'BDD checkout',
        );

        final duplicate = await repository.redeemForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-checkout-order',
          points: 3,
          reason: 'BDD duplicate checkout',
        );

        // Then:
        expect(first.isSuccess, isTrue);
        expect(duplicate.isIdempotent, isTrue);
        expect(await repository.getBalance('customer-1'), 2);
      },
    );

    test(
      'Given an order redeemed 3 points, '
      'When the order refund restores redemption twice, '
      'Then points return exactly once',
      () async {
        // Given:
        await repository.redeemForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-refund-order',
          points: 3,
          reason: 'BDD checkout',
        );

        // When:
        final first = await repository.restoreOrderRedemption(
          orderId: 'bdd-refund-order',
          reason: 'BDD refund',
        );

        final duplicate = await repository.restoreOrderRedemption(
          orderId: 'bdd-refund-order',
          reason: 'BDD duplicate refund',
        );

        // Then:
        expect(first.isSuccess, isTrue);
        expect(duplicate.isIdempotent, isTrue);
        expect(await repository.getBalance('customer-1'), 5);

        final ledger = await repository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) =>
                entry.orderId == 'bdd-refund-order' &&
                entry.type == LoyaltyEntryType.restored,
          ),
          hasLength(1),
        );
      },
    );
  });
}
