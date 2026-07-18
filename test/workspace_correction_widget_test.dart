import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/modules/workspace/controllers/workspace_controller.dart';
import 'package:postgetx/app/modules/auth/views/demo_login_view.dart';
import 'package:postgetx/app/routes/app_pages.dart';
import 'package:postgetx/app/routes/app_routes.dart';
import 'package:postgetx/app/routes/workspace_route_metadata.dart';
import 'package:postgetx/app/theme/app_layout.dart';
import 'package:postgetx/app/theme/app_theme.dart';
import 'package:postgetx/app/shared/widgets/malprax_form_field.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/printer_service.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';

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
    directory =
        await Directory.systemTemp.createTemp('workspace-correction-test');
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
        'workspace-${DateTime.now().microsecondsSinceEpoch}');
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(email: 'owner@demo.local', password: 'owner123');
    Get.put<LocalHiveRepository>(repository, permanent: true);
    Get.put(ThemeController(box), permanent: true);
    controller = Get.put(WorkspaceController(repository, _NoopPrinter()),
        permanent: true);
    await controller.refreshData();
  });

  tearDown(() async {
    Get.reset();
    await box.close();
    await directory.delete(recursive: true);
  });

  Widget app({
    String initialRoute = AppRoutes.cashier,
    ThemeMode themeMode = ThemeMode.dark,
  }) =>
      GetMaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        initialRoute: initialRoute,
        getPages: AppPages.pages,
        routingCallback: (routing) {
          final destination =
              WorkspaceRouteMetadata.tryFromRoute(routing?.current);
          if (destination != null) controller.syncDestination(destination);
        },
      );

  for (final destination in WorkspaceRouteMetadata.destinations) {
    testWidgets('direct route ${destination.route} has one shell title',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(app(initialRoute: destination.route));
      await tester.pumpAndSettle();

      final titleFinder = find.byKey(const ValueKey('active-page-title'));
      expect(titleFinder, findsOneWidget);
      expect(tester.widget<Text>(titleFinder).data, destination.title);
      expect(controller.activePageTitle, destination.title);
      if (destination != WorkspaceRouteMetadata.checkout) {
        final content = find.byKey(
            ValueKey('module-content-${destination.title.toLowerCase()}'));
        expect(content, findsOneWidget);
        expect(
            find.descendant(
                of: content,
                matching: find.text(destination.title, findRichText: false)),
            findsNothing,
            reason: '${destination.title} must not repeat its shell title');
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'sidebar title updates immediately and browser back resynchronizes',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    for (final destination in WorkspaceRouteMetadata.destinations.skip(1)) {
      await tester
          .tap(find.byKey(ValueKey('nav-${destination.title.toLowerCase()}')));
      expect(controller.activePageTitle, destination.title,
          reason: '${destination.title} state changes in the click callback');
      await tester.pumpAndSettle();
      expect(Get.currentRoute, destination.route);
      expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('active-page-title')))
              .data,
          destination.title);
    }

    controller.selectSection('Orders');
    await tester.pumpAndSettle();
    controller.selectSection('Products');
    await tester.pumpAndSettle();
    expect(controller.activePageTitle, 'Products');
    Get.back<void>();
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AppRoutes.orders);
    expect(controller.activePageTitle, 'Orders');
    expect(tester.takeException(), isNull);
  });

  testWidgets('search and single shell divider stay responsive in every mode',
      (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark, ThemeMode.system]) {
      for (final size in [
        const Size(1680, 900),
        const Size(1440, 900),
        const Size(1366, 768),
        const Size(1024, 768),
        const Size(820, 1180),
        const Size(390, 844),
      ]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(app(themeMode: mode));
        await tester.pumpAndSettle();

        final search =
            tester.getSize(find.byKey(const ValueKey('cashier-search')));
        expect(
            search.width, lessThanOrEqualTo(AppLayout.maximumSearchWidth + .1));
        expect(search.width, greaterThan(40));
        final topBar =
            tester.getRect(find.byKey(const ValueKey('cashier-topbar')));
        final divider =
            tester.getRect(find.byKey(const ValueKey('shell-top-divider')));
        expect(divider.left, 0);
        expect(divider.right, size.width);
        expect(divider.height, 1);
        expect(divider.bottom, topBar.bottom);
        expect(tester.takeException(), isNull,
            reason: '$mode at ${size.width}x${size.height}');
      }
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets(
      'product and expense fields expose practical hints and validation',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(initialRoute: AppRoutes.products));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add Product'));
    await tester.pumpAndSettle();

    final productName = find.descendant(
      of: find.byKey(const ValueKey('product-name-field')),
      matching: find.byType(TextField),
    );
    final price = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Price'),
    );
    expect(tester.widget<TextField>(productName).decoration?.hintText,
        'Example: Mineral Water 600ml');
    expect(tester.widget<TextField>(price).keyboardType,
        const TextInputType.numberWithOptions(decimal: true));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    expect(find.text('Product name is required.'), findsOneWidget);
    expect(find.text('SKU is required.'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    controller.selectSection('Expenses');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add Expense'));
    await tester.pumpAndSettle();
    final amount = find.descendant(
      of: find.byKey(const ValueKey('expense-amount-field')),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(amount).decoration?.hintText,
        'Example: 150000');
    expect(tester.widget<TextField>(amount).keyboardType,
        const TextInputType.numberWithOptions(decimal: true));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'fixed and percentage discounts update totals and pay immediately',
      (tester) async {
    tester.view.physicalSize = const Size(1680, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('product-water')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-discount')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fixed'));
    await tester.pump();
    final discountInput = find.descendant(
      of: find.byKey(const ValueKey('discount-input')),
      matching: find.byType(TextField),
    );
    await tester.enterText(discountInput, '1000');
    await tester.tap(find.byKey(const ValueKey('apply-discount')));
    await tester.pumpAndSettle();
    expect(controller.discountType.value, DiscountType.fixed);
    expect(controller.totals.tax, 650);
    expect(controller.totals.total, 7150);
    expect(find.text('Pay ${RupiahFormatter.format(7150)}'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-discount')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Percentage'));
    await tester.pump();
    final percentageInput = find.descendant(
      of: find.byKey(const ValueKey('discount-input')),
      matching: find.byType(TextField),
    );
    await tester.enterText(percentageInput, '20');
    await tester.tap(find.byKey(const ValueKey('apply-discount')));
    await tester.pumpAndSettle();
    expect(controller.discountType.value, DiscountType.percentage);
    expect(controller.totals.discountAmount, 1500);
    expect(controller.totals.tax, 600);
    expect(controller.totals.total, 6600);
    expect(find.text('Pay ${RupiahFormatter.format(6600)}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('none percentage and fixed taxes update pay immediately',
      (tester) async {
    tester.view.physicalSize = const Size(1680, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('product-water')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-tax')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    await tester.tap(find.byKey(const ValueKey('apply-tax')));
    await tester.pumpAndSettle();
    expect(controller.totals.taxAmount, 0);
    expect(find.text('Pay ${RupiahFormatter.format(6750)}'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-tax')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Percentage'));
    await tester.pump();
    final percentage = find.descendant(
        of: find.byKey(const ValueKey('tax-input')),
        matching: find.byType(TextField));
    await tester.enterText(percentage, '20');
    await tester.tap(find.byKey(const ValueKey('apply-tax')));
    await tester.pumpAndSettle();
    expect(controller.totals.taxAmount, 1350);
    expect(find.text('Pay ${RupiahFormatter.format(8100)}'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('edit-tax')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fixed Amount'));
    await tester.pump();
    final fixed = find.descendant(
        of: find.byKey(const ValueKey('tax-input')),
        matching: find.byType(TextField));
    await tester.enterText(fixed, '500');
    await tester.tap(find.byKey(const ValueKey('apply-tax')));
    await tester.pumpAndSettle();
    expect(controller.totals.taxAmount, 500);
    expect(find.text('Pay ${RupiahFormatter.format(7250)}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login fields have examples and inline validation',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: DemoLoginView()));
    await tester.pumpAndSettle();
    final email = find.byKey(const ValueKey('login-email-field'));
    final field = tester.widget<MalpraxFormField>(email);
    final editable = find.descendant(
      of: email,
      matching: find.byType(EditableText),
    );
    expect(field.hint, 'Example: owner@demo.local');
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(tester.widget<EditableText>(editable).keyboardType,
        TextInputType.emailAddress);
    await tester.enterText(editable, 'not-an-email');
    await tester.ensureVisible(find.text('Enter Cashier'));
    await tester.tap(find.text('Enter Cashier'));
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('cash dialog collects exact amount and enables confirmation',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    controller.addProduct(
        controller.products.firstWhere((product) => product.id == 'water'));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pay-order')));
    await tester.pumpAndSettle();
    expect(find.text('Cash Payment'), findsOneWidget);
    expect(
        find.text('Change calculated after sufficient cash'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cash-exact-amount')));
    await tester.pump();
    final confirm = tester.widget<FilledButton>(
        find.byKey(const ValueKey('confirm-cash-payment')));
    expect(confirm.onPressed, isNotNull);
    expect(find.text('Change'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(controller.cart, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('notification menu exposes latest events and View all',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('notifications')));
    await tester.pumpAndSettle();
    expect(find.text('View all notifications'), findsOneWidget);
    expect(find.byKey(const ValueKey('bell-notification-notification-seed-3')),
        findsOneWidget);
    await tester.tap(find.text('View all notifications'));
    await tester.pumpAndSettle();
    expect(find.text('All Notifications'), findsOneWidget);
  });
}
