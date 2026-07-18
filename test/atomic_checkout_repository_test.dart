import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('atomic-pos-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'atomic-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(email: 'owner@demo.local', password: 'owner123');
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  OrderModel sale(
      {String id = 'sale-atomic',
      String productId = 'water',
      int quantity = 2,
      double price = 7500}) {
    final subtotal = price * quantity;
    final discount = subtotal * .1;
    final tax = (subtotal - discount) * .1;
    final total = subtotal - discount + tax;
    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
            id: productId,
            name: productId,
            size: 'Regular',
            price: price,
            quantity: quantity)
      ],
      totalAmount: total,
      discount: discount,
      tax: tax,
      paid: total,
      change: 0,
      createdAt: DateTime.now(),
      createdBy: 'test',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
    );
  }

  test('completed sale decrements stock exactly once and duplicate is rejected',
      () async {
    final before = (await repository.getProducts())
        .firstWhere((p) => p.id == 'water')
        .stock;
    final order = sale();
    final first = await repository.completeSale(order);
    expect(first.isSuccess, isTrue);
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before - 2);

    final duplicate = await repository.completeSale(order);
    expect(duplicate.isSuccess, isFalse);
    expect(duplicate.code, 'already_completed');
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before - 2);
  });

  test(
      'insufficient stock rejects checkout without changing products or orders',
      () async {
    final beforeProducts =
        (await repository.getProducts()).map((p) => p.toMap()).toList();
    final beforeOrders = await repository.getTransactions();
    final result =
        await repository.completeSale(sale(id: 'too-many', quantity: 999));
    expect(result.isSuccess, isFalse);
    expect(result.code, 'insufficient_stock');
    expect((await repository.getProducts()).map((p) => p.toMap()).toList(),
        beforeProducts);
    expect((await repository.getTransactions()).length, beforeOrders.length);
  });

  test('partial write failure rolls products and orders back', () async {
    final failing = LocalHiveRepository.forBox(
      box,
      writeFaultInjector: (stage) {
        if (stage == 'after_products') {
          throw StateError('injected write failure');
        }
      },
    );
    await failing.restoreSession();
    final beforeStock =
        (await failing.getProducts()).firstWhere((p) => p.id == 'water').stock;
    final beforeCount = (await failing.getTransactions()).length;
    final result = await failing.completeSale(sale(id: 'rollback-sale'));
    expect(result.isSuccess, isFalse);
    expect(result.code, 'atomic_write_failed');
    expect(
        (await failing.getProducts()).firstWhere((p) => p.id == 'water').stock,
        beforeStock);
    expect((await failing.getTransactions()).length, beforeCount);
  });

  test('held saved and cancelled open orders never change stock', () async {
    final before = (await repository.getProducts())
        .firstWhere((p) => p.id == 'water')
        .stock;
    final held =
        sale(id: 'held-order').copyWith(status: OrderStatus.held, paid: 0);
    final saved =
        sale(id: 'saved-order').copyWith(status: OrderStatus.saved, paid: 0);
    expect((await repository.saveOpenOrder(held)).isSuccess, isTrue);
    expect((await repository.saveOpenOrder(saved)).isSuccess, isTrue);
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before);

    expect(
        (await repository.cancelOpenOrder(held.id, 'Test cancellation'))
            .isSuccess,
        isTrue);
    expect((await repository.deleteOpenOrder(saved.id)).code,
        'permanent_delete_disabled');
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before);
  });

  test(
      'resumed held order completes under the same ID without duplicate stock mutation',
      () async {
    final before = (await repository.getProducts())
        .firstWhere((p) => p.id == 'water')
        .stock;
    final held =
        sale(id: 'resume-order').copyWith(status: OrderStatus.held, paid: 0);
    expect((await repository.saveOpenOrder(held)).isSuccess, isTrue);

    final completion = await repository.completeSale(held.copyWith(
      status: OrderStatus.draft,
      paid: held.totalAmount,
      sourceOrderId: held.id,
    ));
    expect(completion.isSuccess, isTrue);
    expect(
        (await repository.getTransactions())
            .where((order) => order.id == held.id),
        hasLength(1));
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before - 2);

    expect(
        (await repository.completeSale(held.copyWith(
                status: OrderStatus.draft, paid: held.totalAmount)))
            .isSuccess,
        isFalse);
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before - 2);
  });

  test('completed order cannot be deleted and refund restores stock once',
      () async {
    final before = (await repository.getProducts())
        .firstWhere((p) => p.id == 'water')
        .stock;
    final completed = await repository.completeSale(sale(id: 'refund-sale'));
    expect(completed.isSuccess, isTrue);
    expect((await repository.deleteOpenOrder('refund-sale')).code,
        'permanent_delete_disabled');

    final refund = await repository.refundSale(
        'refund-sale', 'Customer returned sealed goods');
    expect(refund.isSuccess, isTrue);
    expect(refund.value!.status, OrderStatus.refunded);
    expect(refund.value!.stockRestored, isTrue);
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before);

    final duplicate =
        await repository.refundSale('refund-sale', 'Second attempt');
    expect(duplicate.isSuccess, isFalse);
    expect(duplicate.code, 'already_refunded');
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        before);
  });

  test('reset demo data restores consistent lifecycle data and stock',
      () async {
    final initialStock = (await repository.getProducts())
        .firstWhere((p) => p.id == 'water')
        .stock;
    await repository.completeSale(sale(id: 'before-reset'));
    await repository.resetDemoData();
    expect(
        (await repository.getProducts())
            .firstWhere((p) => p.id == 'water')
            .stock,
        initialStock);
    final orders = await repository.getTransactions();
    expect(orders, isNotEmpty);
    expect(
        orders
            .where((order) => order.status == OrderStatus.completed)
            .every((order) => order.stockApplied),
        isTrue);
  });

  test('version 2 maps migrate in place and old records parse safely',
      () async {
    await box.clear();
    await box.put('seedVersion', 2);
    await box.put('transactions', [
      {
        'id': 'legacy',
        'orderId': 'LEGACY',
        'items': [
          CartItemModel(
                  id: 'water',
                  name: 'Water',
                  size: 'Regular',
                  price: 7500,
                  quantity: 1)
              .toMap()
        ],
        'totalAmount': 7500,
        'discount': 0,
        'paid': 7500,
        'change': 0,
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
        'createdBy': 'legacy-user',
      }
    ]);
    await repository.migrateSchema();
    expect(box.get('seedVersion'), LocalHiveRepository.currentSchemaVersion);
    final legacy = (await repository.getTransactions()).single;
    expect(legacy.status, OrderStatus.completed);
    expect(legacy.stockApplied, isTrue);
    expect(legacy.stockRestored, isFalse);
    expect(legacy.taxType, TaxType.none);
    expect(legacy.taxAmount, 0);
  });

  test('version 3 demo seed gains the fifth completed sales product once',
      () async {
    await box.clear();
    await box.put('seedVersion', 3);
    await box.put(
        'transactions',
        List.generate(
            5,
            (index) => {
                  'id': 'seed-${index + 1}',
                  'createdAt': DateTime(2026, 1, index + 1).toIso8601String(),
                }));

    await repository.migrateSchema();
    await repository.migrateSchema();

    final transactions = (box.get('transactions') as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    expect(transactions.where((item) => item['id'] == 'seed-6'), hasLength(1));
    expect(transactions.last['status'], OrderStatus.completed);
  });
}
