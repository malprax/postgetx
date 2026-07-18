import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/app/modules/workspace/views/workspace_view.dart';
import 'package:postgetx/app/modules/workspace/widgets/workspace_sections.dart';
import 'package:postgetx/app/theme/app_theme.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/printer_service.dart';

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
    directory = await Directory.systemTemp.createTemp('active-cashier-layout');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'layout-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(email: 'owner@demo.local', password: 'owner123');
    controller = Get.put(WorkspaceController(
        repository, _NoopPrinter(), repository.loyaltyRepository));
    await controller.refreshData();
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets('product card accepts a bounded grid cell without unbounded flex',
      (tester) async {
    final product = controller.products.first;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 142.7,
            height: 166,
            child: ProductCard(product: product, onTap: () {}),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(product.name), findsOneWidget);
  });

  testWidgets(
      'active cashier renders without layout exceptions at browser widths',
      (tester) async {
    for (final size in [
      const Size(1680, 900),
      const Size(1600, 900),
      const Size(1504, 862),
      const Size(1440, 900),
      const Size(1366, 768),
      const Size(1280, 720),
      const Size(1024, 900),
      const Size(820, 900),
      const Size(390, 900),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(GetMaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const WorkspaceView(),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'active cashier at ${size.width}x${size.height} px');
      expect(find.text('Water Bottle 500ml'), findsWidgets);
      if (size.width >= 1366) {
        final recentTop =
            tester.getTopLeft(find.byKey(const ValueKey('recent-orders'))).dy;
        final sellingTop =
            tester.getTopLeft(find.byKey(const ValueKey('top-selling'))).dy;
        expect((recentTop - sellingTop).abs(), lessThan(.1),
            reason: 'summary panels at ${size.width}x${size.height} px');
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('desktop workstation is dense and all cashier actions are live',
      (tester) async {
    tester.view.physicalSize = const Size(1680, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const WorkspaceView(),
    ));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(const ValueKey('cashier-sidebar'))).width,
        158);
    expect(tester.getSize(find.byKey(const ValueKey('cashier-topbar'))).height,
        66);
    expect(find.byKey(const ValueKey('cashier-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('scan-barcode')), findsOneWidget);
    expect(find.byType(ProductCard), findsNWidgets(10));
    expect(find.byKey(const ValueKey('cart-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('inventory-alerts')), findsOneWidget);
    expect(find.byKey(const ValueKey('today-sales')), findsOneWidget);
    expect(find.byKey(const ValueKey('receipt-status')), findsOneWidget);
    expect(controller.topProducts, hasLength(5));

    await tester.tap(find.byKey(const ValueKey('sidebar-toggle')));
    await tester.pump();
    expect(tester.getSize(find.byKey(const ValueKey('cashier-sidebar'))).width,
        62);
    await tester.tap(find.byKey(const ValueKey('sidebar-toggle')));
    await tester.pump();
    expect(tester.getSize(find.byKey(const ValueKey('cashier-sidebar'))).width,
        158);
    expect(tester.takeException(), isNull, reason: 'sidebar collapse');

    final recentTop =
        tester.getTopLeft(find.byKey(const ValueKey('recent-orders'))).dy;
    final sellingTop =
        tester.getTopLeft(find.byKey(const ValueKey('top-selling'))).dy;
    expect((recentTop - sellingTop).abs(), lessThan(.1));

    final productCards = find.byType(ProductCard);
    final firstRowY = tester.getTopLeft(productCards.at(0)).dy;
    for (var index = 1; index < 5; index++) {
      expect((tester.getTopLeft(productCards.at(index)).dy - firstRowY).abs(),
          lessThan(.1));
    }
    expect(tester.getTopLeft(productCards.at(5)).dy, greaterThan(firstRowY));

    for (final key in [
      'pay-order',
      'hold-order',
      'cancel-order',
      'save-order',
      'more-payments',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey(key)));
      expect(rect.bottom, lessThanOrEqualTo(900), reason: '$key is visible');
    }

    await tester.tap(productCards.at(0));
    await tester.pump();
    expect(find.text('Cart (1)'), findsOneWidget);
    final productId = controller.products.first.id;
    await tester.tap(find.byKey(ValueKey('increase-$productId')));
    await tester.pump();
    expect(find.text('Cart (2)'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'populated cart');
    await tester.tap(find.byKey(const ValueKey('edit-discount')));
    await tester.pumpAndSettle();
    expect(find.text('Order discount'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('more-payments')));
    await tester.pumpAndSettle();
    expect(find.text('Select payment method'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'payment dialogs');

    await tester.tap(find.byKey(const ValueKey('clear-cart')));
    await tester.pump();
    expect(find.byKey(const ValueKey('empty-cart-state')), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('cashier-search')), 'RICE5KG');
    await tester.pump();
    expect(find.byType(ProductCard), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'search result');

    await tester.tap(find.byKey(const ValueKey('scan-barcode')));
    await tester.pumpAndSettle();
    expect(find.text('Scan Barcode'), findsWidgets);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'cashier interactions');

    await tester.tap(find.byKey(const ValueKey('nav-products')));
    await tester.pumpAndSettle();
    expect(controller.activePageTitle, 'Products');
    expect(tester.takeException(), isNull);
  });
}
