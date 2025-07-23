import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/main_drawer.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/sales_chart.dart';

class DashboardAdminView extends StatelessWidget {
  const DashboardAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Get.find<DashboardController>();
    final auth = Get.find<AuthController>();
    final user = auth.currentUserModel.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      drawer: MainDrawer(),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Greeting
                Text('Welcome Admin, ${user?.name ?? ''}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // 📊 Summary Cards
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  children: [
                    DashboardSummaryCard(
                      title: 'Orders Today',
                      value: dashboard.ordersToday.value,
                      icon: Icons.receipt_long,
                      color: Colors.orange,
                    ),
                    DashboardSummaryCard(
                      title: 'Low Stock',
                      value: dashboard.lowStockCount.value,
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    DashboardSummaryCard(
                      title: 'Active Customers',
                      value: dashboard.activeCustomers.value,
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Divider(),

                // 📈 Sales Chart
                const Text('Sales Chart (Last 7 Days)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SalesChart(data: dashboard.salesData),
              ],
            ),
          )),
    );
  }
}
