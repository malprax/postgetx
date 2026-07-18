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
      'postgetx-loyalty-test-',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'loyalty-${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = LocalLoyaltyRepository(
      HiveLoyaltyProvider(box),
      actorId: () => 'demo-owner',
    );
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test('earns points only once per order', () async {
    final first = await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'order-1',
      eligibleAmount: 25000,
    );
    final duplicate = await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'order-1',
      eligibleAmount: 25000,
    );

    expect(first.value?.pointsDelta, 2);
    expect(duplicate.isIdempotent, isTrue);
    expect(await repository.getBalance('customer-1'), 2);
    expect(await repository.getLedger(), hasLength(1));
  });

  test('rejects redemption above available balance', () async {
    final result = await repository.redeem(
      customerId: 'customer-1',
      points: 1,
      reason: 'Reward',
    );

    expect(result.isSuccess, isFalse);
    expect(result.code, 'insufficient_loyalty_points');
    expect(await repository.getBalance('customer-1'), 0);
  });

  test('redeems available points without negative balance', () async {
    await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'order-2',
      eligibleAmount: 50000,
    );

    final result = await repository.redeem(
      customerId: 'customer-1',
      points: 3,
      reason: 'Member reward',
    );

    expect(result.value?.type, LoyaltyEntryType.redeemed);
    expect(result.value?.pointsDelta, -3);
    expect(await repository.getBalance('customer-1'), 2);
  });

  test('reverses order earning idempotently', () async {
    await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'order-3',
      eligibleAmount: 40000,
    );

    final first = await repository.reverseOrderEarning(
      orderId: 'order-3',
      reason: 'Refund',
    );
    final duplicate = await repository.reverseOrderEarning(
      orderId: 'order-3',
      reason: 'Second attempt',
    );

    expect(first.value?.pointsDelta, -4);
    expect(duplicate.isIdempotent, isTrue);
    expect(await repository.getBalance('customer-1'), 0);
  });

  test('provider clear removes local ledger', () async {
    await repository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'order-4',
      eligibleAmount: 30000,
    );

    await HiveLoyaltyProvider(box).clear();

    expect(await repository.getLedger(), isEmpty);
  });
}
