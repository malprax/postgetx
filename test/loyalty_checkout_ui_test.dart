import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/app/modules/workspace/widgets/workspace_sections.dart';
import 'package:postgetx/app/theme/app_theme.dart';

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
      'loyalty-checkout-ui-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'loyalty-checkout-ui-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'checkout-ui-balance',
      eligibleAmount: 50000,
    );

    controller = Get.put(
      WorkspaceController(
        repository,
        _NoopPrinter(),
        repository.loyaltyRepository,
      ),
    );

    await controller.refreshData();

    controller.addProduct(
      controller.products.firstWhere(
        (product) => product.id == 'water',
      ),
    );
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets(
    'cashier selects customer and points before confirming payment',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: CartPanel(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('pay-order')),
      );

      await tester.pumpAndSettle();

      final selector = tester.widget<DropdownButtonFormField<String?>>(
        find.byKey(
          const ValueKey('checkout-customer-selector'),
        ),
      );

      selector.onChanged?.call('customer-1');
      await tester.pump();

      expect(
        find.byKey(const ValueKey('checkout-loyalty-panel')),
        findsOneWidget,
      );

      expect(
        find.text('Available loyalty: 5 points'),
        findsOneWidget,
      );

      final slider = tester.widget<Slider>(
        find.byKey(const ValueKey('checkout-loyalty-slider')),
      );

      slider.onChanged?.call(3);
      await tester.pump();

      expect(controller.loyaltyPointsToRedeem.value, 3);
      expect(controller.totals.loyaltyDiscount, 300);
      expect(
        find.text('3 points = Rp300'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
