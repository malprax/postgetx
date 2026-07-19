import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'postgetx-loyalty-wiring-',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'loyalty-wiring-${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test('main repository exposes the shared local loyalty ledger', () async {
    final loyalty = repository.loyaltyRepository;

    final result = await loyalty.earnForOrder(
      customerId: 'customer-1',
      orderId: 'wiring-order-1',
      eligibleAmount: 30000,
    );

    expect(result.isSuccess, isTrue);
    expect(await loyalty.getBalance('customer-1'), 3);
  });

  test('reset demo data clears the shared loyalty ledger', () async {
    final loyalty = repository.loyaltyRepository;

    await loyalty.earnForOrder(
      customerId: 'customer-1',
      orderId: 'wiring-order-2',
      eligibleAmount: 30000,
    );

    await repository.resetDemoData();

    expect(
      await repository.loyaltyRepository.getBalance('customer-1'),
      0,
    );
  });

  test('schema version includes loyalty ledger migration', () {
    expect(LocalHiveRepository.currentSchemaVersion, 9);
  });
}
