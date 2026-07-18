import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/models/order_lifecycle.dart';
import 'package:postgetx/models/order_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/services/printer_service.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';

class _FakePrinter implements PrinterService {
  OrderModel? lastOrder;

  @override
  Future<void> printOrder(OrderModel order) async => lastOrder = order;
}

class _BlockingPrinter implements PrinterService {
  final started = Completer<void>();
  final release = Completer<void>();

  @override
  Future<void> printOrder(OrderModel order) async {
    if (!started.isCompleted) started.complete();
    await release.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;
  late WorkspaceController controller;
  late _FakePrinter printer;

  setUp(() async {
    Get.testMode = true;
    directory =
        await Directory.systemTemp.createTemp('cashier-controller-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'cashier-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(email: 'owner@demo.local', password: 'owner123');
    printer = _FakePrinter();
    controller = WorkspaceController(repository, printer);
    await controller.refreshData();
  });

  tearDown(() async {
    controller.onClose();
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  test('processing guard prevents duplicate checkout and refreshes UI data',
      () async {
    final product =
        controller.products.firstWhere((item) => item.id == 'water');
    final beforeStock = product.stock;
    final beforeOrders = controller.orders.length;
    controller.addProduct(product);

    await Future.wait([controller.saveOrder(), controller.saveOrder()]);

    expect(controller.cart, isEmpty);
    expect(controller.processingOrder.value, isFalse);
    expect(controller.products.firstWhere((item) => item.id == 'water').stock,
        beforeStock - 1);
    expect(controller.orders.length, beforeOrders + 1);
  });

  test('successful sale can return before browser receipt preview completes',
      () async {
    final blockingPrinter = _BlockingPrinter();
    final nonBlockingController =
        WorkspaceController(repository, blockingPrinter);
    await nonBlockingController.refreshData();
    nonBlockingController.addProduct(nonBlockingController.products
        .firstWhere((item) => item.id == 'water'));

    final completed = await nonBlockingController.saveOrder(print: false);

    expect(completed, isNotNull);
    expect(nonBlockingController.cart, isEmpty);
    expect(nonBlockingController.processingOrder.value, isFalse);
    expect(blockingPrinter.started.isCompleted, isFalse);

    final preview = nonBlockingController.printReceipt(completed!);
    await blockingPrinter.started.future;
    expect(blockingPrinter.release.isCompleted, isFalse);
    blockingPrinter.release.complete();
    await preview;
    nonBlockingController.onClose();
  });

  test('failed checkout keeps cart intact and does not mutate stock', () async {
    final product =
        controller.products.firstWhere((item) => item.id == 'water');
    controller.addProduct(product);
    await repository.updateProduct(product.copyWith(stock: 0));

    await controller.saveOrder();

    expect(controller.cart, hasLength(1));
    expect(
        (await repository.getProducts())
            .firstWhere((item) => item.id == 'water')
            .stock,
        0);
    expect(
        (await repository.getTransactions())
            .any((order) => order.orderId.startsWith('T-')),
        isFalse);
  });

  test('refund refreshes stock and order lifecycle in controller', () async {
    final product =
        controller.products.firstWhere((item) => item.id == 'water');
    final beforeStock = product.stock;
    controller.addProduct(product);
    await controller.saveOrder();
    final completed =
        controller.orders.firstWhere((order) => order.orderId.startsWith('T-'));
    expect(controller.products.firstWhere((item) => item.id == 'water').stock,
        beforeStock - 1);

    await controller.refundOrder(completed.id, 'Controller refund test');

    expect(controller.products.firstWhere((item) => item.id == 'water').stock,
        beforeStock);
    expect(
        controller.orders
            .firstWhere((order) => order.id == completed.id)
            .status,
        OrderStatus.refunded);
  });

  test('displayed persisted and receipt totals share one snapshot', () async {
    final product =
        controller.products.firstWhere((item) => item.id == 'water');
    controller.addProduct(product);
    controller.setDiscount(DiscountType.fixed, 1000);

    final displayed = controller.totals;
    expect(displayed.subtotal, 7500);
    expect(displayed.discountAmount, 1000);
    expect(displayed.taxableAmount, 6500);
    expect(displayed.tax, 650);
    expect(displayed.total, 7150);

    await controller.saveOrder(print: true);

    final persisted =
        controller.orders.firstWhere((order) => order.orderId.startsWith('T-'));
    final receipt = ReceiptData.fromOrder(persisted);
    expect(persisted.subtotal, displayed.subtotal);
    expect(persisted.discount, displayed.discountAmount);
    expect(persisted.tax, displayed.tax);
    expect(persisted.totalAmount, displayed.total);
    expect(receipt.subtotal, persisted.subtotal);
    expect(receipt.discountAmount, persisted.discount);
    expect(receipt.tax, persisted.tax);
    expect(receipt.total, persisted.totalAmount);
    expect(receipt.amountPaid, persisted.paid);
    expect(receipt.change, persisted.change);
    expect(printer.lastOrder?.id, persisted.id);
    expect(printer.lastOrder?.totalAmount, persisted.totalAmount);
  });
}
