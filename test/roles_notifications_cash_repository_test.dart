import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('roles-cash-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'roles-cash-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  OrderModel sale(String id,
      {double received = 7500, String status = OrderStatus.draft}) {
    final items = [
      CartItemModel(
          id: 'water',
          name: 'Water Bottle 500ml',
          size: 'Regular',
          price: 7500,
          quantity: 1),
    ];
    final totals = const PosTotalCalculator().calculate(
      items: items,
      discountType: DiscountType.fixed,
      discountValue: 0,
      taxType: TaxType.none,
      taxValue: 0,
      amountPaid: received,
    );
    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: items,
      subtotal: totals.subtotal,
      discount: totals.discountAmount,
      discountType: totals.discountType,
      discountValue: totals.discountValue,
      taxableAmount: totals.taxableAmount,
      taxType: totals.taxType,
      taxValue: totals.taxValue,
      taxAmount: totals.taxAmount,
      totalAmount: totals.total,
      paid: received,
      amountReceived: received,
      amountApplied: totals.total,
      change: totals.change,
      paymentMethod: 'cash',
      createdAt: DateTime.now(),
      createdBy: '',
      status: status,
      receiptStatus: ReceiptState.pending,
    );
  }

  test('owner and staff credentials persist sessions and logout clears them',
      () async {
    final owner =
        await repository.login(email: 'owner@demo.local', password: 'owner123');
    expect(owner.role, UserRole.owner);
    expect(repository.hasPermission(AppPermission.restoreOrder), isTrue);

    final reloaded = LocalHiveRepository.forBox(box);
    expect((await reloaded.restoreSession())?.id, owner.id);
    await reloaded.logout();
    expect(await LocalHiveRepository.forBox(box).restoreSession(), isNull);

    final staff =
        await repository.login(email: 'staff@demo.local', password: 'staff123');
    expect(staff.role, UserRole.staff);
    expect(repository.hasPermission(AppPermission.createTransaction), isTrue);
    expect(repository.hasPermission(AppPermission.manageProducts), isFalse);
    expect(
        repository.hasPermission(AppPermission.refundCompletedOrder), isFalse);
  });

  test('repository rejects forbidden staff mutations authoritatively',
      () async {
    await repository.login(email: 'staff@demo.local', password: 'staff123');
    await expectLater(repository.adjustStock('water', 1), throwsStateError);
    final refund = await repository.refundSale('seed-1', 'Not allowed');
    expect(refund.code, 'permission_denied');
    final deletion = await repository.softDeleteOrder('seed-1', 'Not allowed');
    expect(deletion.code, 'permission_denied');
  });

  test(
      'cash checkout persists exact and overpayment and rejects insufficient cash',
      () async {
    await repository.login(email: 'owner@demo.local', password: 'owner123');
    final before = (await repository.getProducts())
        .firstWhere((product) => product.id == 'water')
        .stock;

    final exact = await repository.completeSale(sale('cash-exact'));
    expect(exact.isSuccess, isTrue);
    expect(exact.value!.amountReceived, 7500);
    expect(exact.value!.amountApplied, 7500);
    expect(exact.value!.change, 0);
    expect(exact.value!.paymentMethod, 'cash');
    expect(exact.value!.paidAt, isNotNull);

    final over =
        await repository.completeSale(sale('cash-over', received: 10000));
    expect(over.isSuccess, isTrue);
    expect(over.value!.change, 2500);
    final receipt = ReceiptData.fromOrder(over.value!);
    expect(receipt.paymentMethod, over.value!.paymentMethod);
    expect(receipt.amountPaid, over.value!.amountReceived);
    expect(receipt.amountApplied, over.value!.amountApplied);
    expect(receipt.change, over.value!.change);

    final notificationCount = (await repository.getNotifications()).length;
    final insufficient =
        await repository.completeSale(sale('cash-under', received: 7000));
    expect(insufficient.code, 'payment_insufficient');
    expect((await repository.getNotifications()).length, notificationCount);
    expect(
        (await repository.getTransactions())
            .where((order) => order.id == 'cash-under'),
        isEmpty);
    expect(
        (await repository.getProducts())
            .firstWhere((product) => product.id == 'water')
            .stock,
        before - 2);
  });

  test(
      'hold save cancellation soft delete restore and notifications are auditable',
      () async {
    final owner =
        await repository.login(email: 'owner@demo.local', password: 'owner123');
    final beforeStock = (await repository.getProducts())
        .firstWhere((product) => product.id == 'water')
        .stock;

    final held = await repository.saveOpenOrder(
        sale('audit-held', received: 0, status: OrderStatus.held));
    expect(held.isSuccess, isTrue);
    final saved = await repository.saveOpenOrder(
        sale('audit-saved', received: 0, status: OrderStatus.saved).copyWith(
            customerName: 'Walk-in Business', notes: 'Collect at 5 PM'));
    expect(saved.value!.notes, 'Collect at 5 PM');
    expect(
        (await repository.getProducts())
            .firstWhere((product) => product.id == 'water')
            .stock,
        beforeStock);

    final cancelled =
        await repository.cancelOpenOrder('audit-held', 'Customer left');
    expect(cancelled.value!.cancelledBy, owner.id);
    expect(cancelled.value!.cancellationReason, 'Customer left');

    final deleted =
        await repository.softDeleteOrder('audit-saved', 'Duplicate record');
    expect(deleted.value!.isDeleted, isTrue);
    expect(
        (await repository.getTransactions())
            .where((order) => order.id == 'audit-saved'),
        isEmpty);
    expect(
        (await repository.getTransactions(includeDeleted: true))
            .where((order) => order.id == 'audit-saved'),
        hasLength(1));

    final restored = await repository.restoreOrder('audit-saved');
    expect(restored.value!.isDeleted, isFalse);
    expect(restored.value!.restoredBy, owner.id);
    expect(
        (await repository.getProducts())
            .firstWhere((product) => product.id == 'water')
            .stock,
        beforeStock);

    final notifications = await repository.getNotifications();
    expect(notifications.any((item) => item.type == 'orderHeld'), isTrue);
    expect(notifications.any((item) => item.type == 'orderSaved'), isTrue);
    expect(notifications.any((item) => item.type == 'orderCancelled'), isTrue);
    expect(
        notifications.any((item) => item.type == 'recordSoftDeleted'), isTrue);
    expect(notifications.any((item) => item.type == 'recordRestored'), isTrue);
    expect(notifications.first.actorId, owner.id);
    expect(await repository.getNotifications(limit: 5), hasLength(5));
    expect(
        notifications.take(5).map((item) => item.createdAt).toList(),
        orderedEquals(
            notifications.take(5).map((item) => item.createdAt).toList()
              ..sort((a, b) => b.compareTo(a))));

    final reloaded = LocalHiveRepository.forBox(box);
    expect((await reloaded.getNotifications()).map((item) => item.id),
        containsAll(notifications.map((item) => item.id)));

    await repository.markNotificationRead(notifications.first.id, isRead: true);
    expect(
        (await repository.getNotifications())
            .firstWhere((item) => item.id == notifications.first.id)
            .isRead,
        isTrue);
    await repository.markAllNotificationsRead();
    expect((await repository.getNotifications()).every((item) => item.isRead),
        isTrue);
  });
}
