import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'loyalty-checkout-integration-',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'loyalty-checkout-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  OrderModel sale(String id) {
    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
          id: 'water',
          name: 'Mineral Water',
          size: 'Regular',
          price: 20000,
          quantity: 2,
        ),
      ],
      totalAmount: 40000,
      discount: 0,
      tax: 0,
      paid: 40000,
      change: 0,
      createdAt: DateTime.now(),
      createdBy: 'test',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
      customerId: 'customer-1',
      customerName: 'Budi Santoso',
    );
  }

  test('completed customer sale earns points automatically', () async {
    final result = await repository.completeSale(
      sale('loyalty-sale'),
    );

    expect(result.isSuccess, isTrue);
    expect(
      await repository.loyaltyRepository.getBalance('customer-1'),
      4,
    );

    final ledger = await repository.loyaltyRepository.getLedger(
      customerId: 'customer-1',
    );

    expect(ledger, hasLength(1));
    expect(ledger.single.orderId, 'loyalty-sale');
    expect(ledger.single.pointsDelta, 4);
  });

  test('duplicate checkout never earns points twice', () async {
    final order = sale('duplicate-loyalty-sale');

    expect(
      (await repository.completeSale(order)).isSuccess,
      isTrue,
    );

    final duplicate = await repository.completeSale(order);

    expect(duplicate.isSuccess, isFalse);
    expect(duplicate.code, 'already_completed');
    expect(
      await repository.loyaltyRepository.getBalance('customer-1'),
      4,
    );
  });

  test('refund reverses earned points exactly once', () async {
    final order = sale('refund-loyalty-sale');

    expect(
      (await repository.completeSale(order)).isSuccess,
      isTrue,
    );

    final refund = await repository.refundSale(
      order.id,
      'Customer returned sealed goods',
    );

    expect(refund.isSuccess, isTrue);
    expect(
      await repository.loyaltyRepository.getBalance('customer-1'),
      0,
    );

    final duplicate = await repository.refundSale(
      order.id,
      'Second refund attempt',
    );

    expect(duplicate.isSuccess, isFalse);
    expect(duplicate.code, 'already_refunded');

    final ledger = await repository.loyaltyRepository.getLedger(
      customerId: 'customer-1',
    );

    expect(ledger, hasLength(2));
  });

  test('failure after loyalty write rolls back sale stock order and points',
      () async {
    final failing = LocalHiveRepository.forBox(
      box,
      writeFaultInjector: (stage) {
        if (stage == 'after_loyalty') {
          throw StateError('Injected loyalty write failure');
        }
      },
    );

    await failing.restoreSession();

    final stockBefore = (await failing.getProducts())
        .firstWhere((product) => product.id == 'water')
        .stock;
    final orderCountBefore = (await failing.getTransactions()).length;

    final result = await failing.completeSale(
      sale('rollback-loyalty-sale'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.code, 'atomic_write_failed');

    expect(
      (await failing.getProducts())
          .firstWhere((product) => product.id == 'water')
          .stock,
      stockBefore,
    );

    expect(
      (await failing.getTransactions()).length,
      orderCountBefore,
    );

    expect(
      await failing.loyaltyRepository.getBalance('customer-1'),
      0,
    );
  });
}
