import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';

class _NoopPrinter implements PrinterService {
  @override
  Future<void> printOrder(OrderModel order) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;
  late WorkspaceController controller;

  setUp(() async {
    Get.testMode = true;

    directory = await Directory.systemTemp.createTemp(
      'bdd-loyalty-checkout-e2e-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-loyalty-e2e-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'e2e-balance-source',
      eligibleAmount: 50000,
    );

    controller = WorkspaceController(
      repository,
      _NoopPrinter(),
      repository.loyaltyRepository,
    );

    await controller.refreshData();
  });

  tearDown(() async {
    controller.onClose();
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'Given a customer has loyalty points, '
    'When cashier pays with points and later refunds, '
    'Then order ledger receipt stock and balance remain consistent',
    () async {
      // Given:
      final customer = controller.customers.firstWhere(
        (item) => item.id == 'customer-1',
      );

      final product = controller.products.firstWhere(
        (item) => item.id == 'water',
      );

      final stockBefore = product.stock;

      controller.addProduct(product);
      controller.selectCheckoutCustomer(customer);
      controller.setLoyaltyPointsToRedeem(3);

      final checkoutTotal = controller.totals.total;

      expect(controller.availableCheckoutPoints, 5);
      expect(controller.checkoutLoyaltyDiscount, 300);

      // When:
      final completed = await controller.saveOrder(
        amountReceived: checkoutTotal,
        paymentMethod: 'cash',
      );

      // Then:
      expect(completed, isNotNull);
      expect(completed!.status, OrderStatus.completed);
      expect(completed.customerId, customer.id);
      expect(completed.loyaltyPointsRedeemed, 3);
      expect(completed.loyaltyDiscount, 300);
      expect(completed.loyaltyPointsEarned, 0);
      expect(completed.loyaltyBalanceAfter, 2);

      expect(
        controller.products.firstWhere((item) => item.id == product.id).stock,
        stockBefore - 1,
      );

      final receipt = ReceiptData.fromOrder(completed);

      expect(receipt.customerName, customer.name);
      expect(receipt.loyaltyPointsRedeemed, 3);
      expect(receipt.loyaltyDiscount, 300);
      expect(receipt.loyaltyBalanceAfter, 2);
      expect(receipt.total, checkoutTotal);

      var ledger = await repository.loyaltyRepository.getLedger(
        customerId: customer.id,
      );

      expect(
        ledger.where(
          (entry) =>
              entry.orderId == completed.id &&
              entry.type == LoyaltyEntryType.redeemed,
        ),
        hasLength(1),
      );

      expect(
        await repository.loyaltyRepository.getBalance(customer.id),
        2,
      );

      // When:
      await controller.refundOrder(
        completed.id,
        'BDD full loyalty refund',
      );

      // Then:
      final refunded = controller.orders.firstWhere(
        (order) => order.id == completed.id,
      );

      expect(refunded.status, OrderStatus.refunded);

      expect(
        controller.products.firstWhere((item) => item.id == product.id).stock,
        stockBefore,
      );

      expect(
        await repository.loyaltyRepository.getBalance(customer.id),
        5,
      );

      ledger = await repository.loyaltyRepository.getLedger(
        customerId: customer.id,
      );

      expect(
        ledger.where(
          (entry) =>
              entry.orderId == completed.id &&
              entry.type == LoyaltyEntryType.restored,
        ),
        hasLength(1),
      );

      expect(
        ledger.where(
          (entry) =>
              entry.orderId == completed.id &&
              entry.type == LoyaltyEntryType.redeemed,
        ),
        hasLength(1),
      );
    },
  );
}
