// dashboard_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  final RxInt ordersToday = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxInt activeCustomers = 0.obs;

  final RxList<Map<String, dynamic>> salesData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    fetchDashboardStats();
    fetchSalesChart();
    super.onInit();
  }

  Future<void> fetchDashboardStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    // Orders today
    final orderSnap = await FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThan: end)
        .get();
    ordersToday.value = orderSnap.docs.length;

    // Low stock
    final stockSnap = await FirebaseFirestore.instance
        .collection('products')
        .where('stock', isLessThanOrEqualTo: 5)
        .get();
    lowStockCount.value = stockSnap.docs.length;

    // Active customers
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .where('isActive', isEqualTo: true)
        .get();
    activeCustomers.value = userSnap.docs.length;
  }

  Future<void> fetchSalesChart() async {
    final now = DateTime.now();
    List<Map<String, dynamic>> chart = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));

      final orders = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end)
          .get();

      chart.add({
        'day': '${start.day}/${start.month}',
        'total': orders.docs.length,
      });
    }

    salesData.assignAll(chart);
  }
}
