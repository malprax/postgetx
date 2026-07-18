import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/app/routes/app_pages.dart';
import 'package:postgetx/app/routes/app_routes.dart';
import 'package:postgetx/app/routes/workspace_route_metadata.dart';
import 'package:postgetx/app/theme/app_theme.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';
import 'package:postgetx/app/data/providers/local/theme_preferences_provider.dart';

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
    directory = await Directory.systemTemp.createTemp('staff-widget-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'staff-widget-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(email: 'staff@demo.local', password: 'staff123');
    Get.put<LocalHiveRepository>(repository, permanent: true);
    Get.put(ThemeController(ThemePreferencesProvider(box)), permanent: true);
    controller = Get.put(
        WorkspaceController(
            repository, _NoopPrinter(), repository.loyaltyRepository),
        permanent: true);
    await controller.refreshData();
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets('Staff direct route and sidebar hide Owner actions',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    controller.syncDestination(WorkspaceRouteMetadata.checkout);

    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.trash,
      getPages: AppPages.pages,
      routingCallback: (routing) {
        final destination =
            WorkspaceRouteMetadata.tryFromRoute(routing?.current);
        if (destination != null) controller.syncDestination(destination);
      },
    ));
    await tester.pumpAndSettle();

    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('active-page-title')))
            .data,
        'Checkout');
    expect(find.text('Products'), findsNothing);
    expect(find.text('Inventory'), findsNothing);
    expect(find.text('Expenses'), findsNothing);
    expect(find.text('Settings'), findsNothing);
    expect(find.text('Trash'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
