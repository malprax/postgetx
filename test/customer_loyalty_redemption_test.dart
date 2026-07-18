import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
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
      'customer-loyalty-redemption-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'customer-loyalty-redemption-'
      '${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'redemption-ui-order',
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

  test('controller rejects redemption above available balance', () async {
    final result = await controller.redeemCustomerPoints(
      customerId: 'customer-1',
      points: 4,
      reason: 'Too many points',
    );

    expect(result.isSuccess, isFalse);
    expect(result.code, 'insufficient_loyalty_points');
    expect(controller.loyaltyBalanceFor('customer-1'), 3);
  });

  test('controller redeems points and refreshes observable balance', () async {
    final result = await controller.redeemCustomerPoints(
      customerId: 'customer-1',
      points: 2,
      reason: 'Member reward',
    );

    expect(result.isSuccess, isTrue);
    expect(controller.loyaltyBalanceFor('customer-1'), 1);

    final ledger = await repository.loyaltyRepository.getLedger(
      customerId: 'customer-1',
    );

    final redemption = ledger.firstWhere(
      (entry) => entry.type == LoyaltyEntryType.redeemed,
    );

    expect(redemption.pointsDelta, -2);
    expect(redemption.reason, 'Member reward');
  });

  testWidgets('redemption form validates input and calculates reward value',
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

    await tester.tap(find.byTooltip('View loyalty points').first);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('redeem-points-customer-1')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('redeem-points-field')),
      '2',
    );

    await tester.enterText(
      find.byKey(const ValueKey('redeem-reason-field')),
      'Member reward',
    );

    await tester.pump();

    expect(find.text('Reward value: Rp200'), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('confirm-redeem-points')),
    );

    expect(button.onPressed, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('redeem-points-field')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
