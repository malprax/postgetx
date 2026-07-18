import 'package:get/get.dart';

import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

class DashboardController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();

  final ordersToday = 0.obs;
  final todaySales = 0.0.obs;
  final lowStockCount = 0.obs;
  final activeCustomers = 0.obs;
  final salesData = <Map<String, dynamic>>[].obs;
  final revision = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    final orders = await repository.getTransactions();
    final products = await repository.getProducts();
    final customers = await repository.getCustomers();
    final now = DateTime.now();

    final todayOrders = orders.where(
      (order) =>
          order.createdAt.year == now.year &&
          order.createdAt.month == now.month &&
          order.createdAt.day == now.day,
    );

    ordersToday.value = todayOrders.length;

    todaySales.value = todayOrders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    lowStockCount.value = products
        .where(
          (product) => product.stock <= product.lowStockThreshold,
        )
        .length;

    activeCustomers.value = customers.length;

    salesData.assignAll(
      List.generate(7, (index) {
        final day = DateTime(now.year, now.month, now.day).subtract(
          Duration(days: 6 - index),
        );

        final total = orders
            .where(
              (order) =>
                  order.createdAt.year == day.year &&
                  order.createdAt.month == day.month &&
                  order.createdAt.day == day.day,
            )
            .fold<double>(
              0,
              (sum, order) => sum + order.totalAmount,
            );

        return {
          'day': '${day.day}/${day.month}',
          'total': total,
        };
      }),
    );

    revision.value++;
  }

  Future<void> fetchDashboardStats() => refreshDashboard();

  Future<void> fetchSalesChart() => refreshDashboard();
}
