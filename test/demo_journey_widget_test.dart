import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/config/app_config.dart';
import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/modules/auth/controllers/auth_controller.dart';
import 'package:postgetx/app/modules/auth/views/login_view.dart';
import 'package:postgetx/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:postgetx/app/modules/dashboard/views/dashboard_admin_view.dart';
import 'package:postgetx/app/modules/pos/controllers/pos_controller.dart';
import 'package:postgetx/app/modules/pos/views/pos_view.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/routes/app_routes.dart';
import 'package:postgetx/app/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    Get.testMode = true;
    directory = await Directory.systemTemp.createTemp('retail-widget-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'widget-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    Get.put<LocalHiveRepository>(repository, permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  testWidgets('demo entry exposes visible seeded credentials', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: Routes.login,
      getPages: [
        GetPage(name: Routes.login, page: () => LoginView()),
        GetPage(
            name: Routes.dashboard,
            page: () => const Scaffold(body: Text('dashboard-ready'))),
      ],
    ));
    expect(find.text(AppConfig.demoEmail, findRichText: true), findsWidgets);
    await tester.ensureVisible(find.text('Enter Demo'));
    expect(find.widgetWithText(FilledButton, 'Enter Demo'), findsOneWidget);
    expect(
        Get.find<AuthController>().emailController.text, AppConfig.demoEmail);
    expect(Get.find<AuthController>().passwordController.text,
        AppConfig.demoPassword);
  });

  testWidgets(
      'dashboard and cashier have no layout exceptions at launch widths',
      (tester) async {
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController(), permanent: true);
    auth.currentUserModel.value = UserModel(
        uid: 'demo-admin',
        email: AppConfig.demoEmail,
        name: 'Demo Admin',
        role: 'admin',
        isActive: true);
    Get.put(DashboardController());
    Get.put(PosController());
    for (final width in [1440.0, 1024.0, 820.0, 390.0]) {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(GetMaterialApp(
          theme: AppTheme.light, home: const DashboardAdminView()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'dashboard at $width px');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.takeException();
      await tester
          .pumpWidget(GetMaterialApp(theme: AppTheme.light, home: PosView()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'cashier at $width px');
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
