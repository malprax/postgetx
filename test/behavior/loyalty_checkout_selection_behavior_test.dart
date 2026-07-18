import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';

class _NoopPrinter implements PrinterService {
  @override
  Future<void> printOrder(OrderModel order) async {}
}

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;
  late WorkspaceController controller;

  setUp(() async {
    Get.testMode = true;

    directory = await Directory.systemTemp.createTemp(
      'bdd-loyalty-checkout-selection-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-loyalty-selection-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'bdd-checkout-balance',
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

  group('Feature: Cashier selects customer loyalty at checkout', () {
    test(
      'Given a customer has 5 points, '
      'When cashier selects the customer and requests 3 points, '
      'Then checkout applies a Rp300 loyalty discount',
      () {
        // Given:
        final customer = controller.customers.firstWhere(
          (item) => item.id == 'customer-1',
        );

        final product = controller.products.firstWhere(
          (item) => item.id == 'water',
        );

        controller.addProduct(product);

        // When:
        controller.selectCheckoutCustomer(customer);
        controller.setLoyaltyPointsToRedeem(3);

        // Then:
        expect(controller.availableCheckoutPoints, 5);
        expect(controller.loyaltyPointsToRedeem.value, 3);
        expect(controller.checkoutLoyaltyDiscount, 300);
        expect(controller.totals.loyaltyDiscount, 300);
        expect(controller.totals.taxableAmount, 6450);
        expect(controller.totals.taxAmount, 645);
        expect(controller.totals.total, 7095);
      },
    );

    test(
      'Given a customer has only 5 points, '
      'When cashier requests 99 points, '
      'Then checkout caps redemption at the available balance',
      () {
        // Given:
        final customer = controller.customers.firstWhere(
          (item) => item.id == 'customer-1',
        );

        // When:
        controller.selectCheckoutCustomer(customer);
        controller.setLoyaltyPointsToRedeem(99);

        // Then:
        expect(controller.loyaltyPointsToRedeem.value, 5);
        expect(controller.checkoutLoyaltyDiscount, 500);
      },
    );

    test(
      'Given loyalty points are selected, '
      'When cashier removes the customer, '
      'Then pending redemption is cleared',
      () {
        // Given:
        final customer = controller.customers.firstWhere(
          (item) => item.id == 'customer-1',
        );

        controller.selectCheckoutCustomer(customer);
        controller.setLoyaltyPointsToRedeem(3);

        // When:
        controller.selectCheckoutCustomer(null);

        // Then:
        expect(controller.selectedCheckoutCustomer.value, isNull);
        expect(controller.loyaltyPointsToRedeem.value, 0);
        expect(controller.checkoutLoyaltyDiscount, 0);
      },
    );
  });
}
