import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/app/modules/workspace/widgets/crud_sections.dart';
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
      'customer-loyalty-ui-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'customer-loyalty-ui-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'ui-loyalty-order',
      eligibleAmount: 30000,
    );

    controller = Get.put(
      WorkspaceController(
        repository,
        _NoopPrinter(),
        repository.loyaltyRepository,
      ),
    );

    await controller.refreshData();
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets('customer table shows balance and opens loyalty ledger',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CrudSection(section: 'Customers'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('loyalty-balance-customer-1')),
      findsOneWidget,
    );
    expect(find.text('3 pts'), findsOneWidget);

    await tester.tap(find.byTooltip('View loyalty points').first);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('loyalty-dialog-balance-customer-1')),
      findsOneWidget,
    );
    expect(find.text('3 points'), findsOneWidget);
    expect(find.text('Points earned'), findsOneWidget);
    expect(find.text('+3 pts'), findsOneWidget);
    expect(find.textContaining('ui-loyalty-order'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
