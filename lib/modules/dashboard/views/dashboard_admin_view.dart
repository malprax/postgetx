import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/app_config.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/demo_mode_banner.dart';
import '../../../widgets/main_drawer.dart';
import 'package:postgetx/app/modules/auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/sales_chart.dart';

class DashboardAdminView extends StatelessWidget {
  const DashboardAdminView({super.key});
  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final user = Get.find<AuthController>().currentUserModel.value;
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.productName), actions: [
        IconButton(
            onPressed: dashboard.refreshDashboard,
            tooltip: 'Refresh local metrics',
            icon: const Icon(Icons.refresh))
      ]),
      drawer: MainDrawer(),
      body: Column(children: [
        const DemoModeBanner(),
        Expanded(
            child: RefreshIndicator(
                onRefresh: dashboard.refreshDashboard,
                child: Obx(() {
                  dashboard.revision.value;
                  return LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100
                        ? 4
                        : constraints.maxWidth >= 700
                            ? 2
                            : 1;
                    return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text('Welcome, ${user?.name ?? 'Demo visitor'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                              'Complete a sample sale, then return here to see live local totals.'),
                          const SizedBox(height: 20),
                          GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: columns,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: columns == 1 ? 4 : 2.4,
                              children: [
                                DashboardSummaryCard(
                                    title: 'Transactions Today',
                                    value: dashboard.ordersToday.value,
                                    icon: Icons.receipt_long,
                                    color: Colors.orange),
                                DashboardSummaryCard(
                                    title: 'Sales Today',
                                    value: dashboard.todaySales.value.round(),
                                    icon: Icons.payments_outlined,
                                    color: Colors.blue),
                                DashboardSummaryCard(
                                    title: 'Low Stock',
                                    value: dashboard.lowStockCount.value,
                                    icon: Icons.warning_amber_rounded,
                                    color: Colors.red),
                                DashboardSummaryCard(
                                    title: 'Active Customers',
                                    value: dashboard.activeCustomers.value,
                                    icon: Icons.people,
                                    color: Colors.green),
                              ]),
                          const SizedBox(height: 20),
                          Wrap(spacing: 12, runSpacing: 12, children: [
                            FilledButton.icon(
                                onPressed: () => Get.toNamed(Routes.pos),
                                icon: const Icon(Icons.point_of_sale),
                                label: const Text('Open POS / Cashier')),
                            OutlinedButton.icon(
                                onPressed: () =>
                                    Get.toNamed(Routes.orderHistory),
                                icon: const Icon(Icons.history),
                                label: const Text('Transaction History'))
                          ]),
                          const SizedBox(height: 28),
                          Text('Sales — last 7 days',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                      height: 260,
                                      child: SalesChart(
                                          data: dashboard.salesData)))),
                          const SizedBox(height: 16),
                          const Text(AppConfig.versionLabel,
                              textAlign: TextAlign.center),
                        ]);
                  });
                })))
      ]),
    );
  }
}
