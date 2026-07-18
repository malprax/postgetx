import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:postgetx/config/app_config.dart';
import 'package:postgetx/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:postgetx/app/modules/orders/controllers/order_history_controller.dart';
import 'package:postgetx/app/modules/pos/controllers/pos_controller.dart';
import 'package:postgetx/app/modules/category/controllers/category_controller.dart';
import 'package:postgetx/app/modules/menu/controllers/menu_controller.dart'
    as app_menu;
import 'package:postgetx/app/modules/users/controllers/user_controller.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/settings/controllers/theme_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool resetting = false;
  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text('Reset demo data?'),
                    content: const Text(
                        'Products, categories, customers, and transactions will return to their original demo state. Theme preference is preserved.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'))
                    ])) ??
        false;
    if (!confirmed) return;
    setState(() => resetting = true);
    await Get.find<LocalHiveRepository>().resetDemoData();
    if (Get.isRegistered<PosController>()) {
      final c = Get.find<PosController>();
      c.resetCart();
      await c.fetchCategories();
      await c.fetchMenus();
    }
    if (Get.isRegistered<OrderHistoryController>()) {
      await Get.find<OrderHistoryController>().fetchOrders();
    }
    if (Get.isRegistered<CategoryController>()) {
      await Get.find<CategoryController>().fetchCategories();
    }
    if (Get.isRegistered<app_menu.MenuController>()) {
      await Get.find<app_menu.MenuController>().fetchCategories();
      await Get.find<app_menu.MenuController>().fetchMenuItems();
    }
    if (Get.isRegistered<UsersController>()) {
      await Get.find<UsersController>().fetchUsers();
    }
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().refreshDashboard();
    }
    if (mounted) {
      setState(() => resetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data reset successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Scaffold(
        appBar: AppBar(title: const Text('Demo Settings')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Obx(() => SegmentedButton<AppThemePreference>(segments: const [
                ButtonSegment(
                    value: AppThemePreference.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light')),
                ButtonSegment(
                    value: AppThemePreference.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark')),
                ButtonSegment(
                    value: AppThemePreference.auto,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('Auto'))
              ], selected: {
                theme.preference.value
              }, onSelectionChanged: (value) => theme.select(value.first))),
          const SizedBox(height: 28),
          Text('Demo data', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
              child: ListTile(
                  title: const Text('Reset Demo Data'),
                  subtitle: const Text(
                      'Restore the original local seed without changing your theme.'),
                  trailing: resetting
                      ? const SizedBox.square(
                          dimension: 24, child: CircularProgressIndicator())
                      : const Icon(Icons.restart_alt),
                  onTap: resetting ? null : _reset)),
          const SizedBox(height: 28),
          const Text(AppConfig.productName),
          const Text(AppConfig.versionLabel),
          const Text('No cloud backend. No real payments.'),
        ]));
  }
}
