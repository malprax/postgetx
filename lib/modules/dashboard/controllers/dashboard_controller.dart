// dashboard_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  final RxInt ordersToday = 0.obs;
  final RxInt lowStockCount = 0.obs;
  final RxInt activeCustomers = 0.obs;

  final RxList<Map<String, dynamic>> salesData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    debugAuthContext();
    fetchDashboardStats();
    fetchSalesChart();
    super.onInit();
  }

  Future<void> debugAuthContext() async {
    final u = FirebaseAuth.instance.currentUser;
    await u?.getIdToken(true); // force refresh token

    final token = await u?.getIdTokenResult(true);
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(u!.uid).get();

    debugPrint('DBG uid=${u.uid}');
    debugPrint('DBG token.role=${token?.claims?['role']}');
    debugPrint('DBG users.role=${doc.data()?['role']}');
  }

  Future<void> fetchDashboardStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final startTs = Timestamp.fromDate(start);
    final endTs = Timestamp.fromDate(end);

    // Orders today
    try {
      final orderSnap = await FirebaseFirestore.instance
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startTs)
          .where('createdAt', isLessThan: endTs)
          .get();
      ordersToday.value = orderSnap.docs.length;
    } catch (e) {
      print('error fetching orders today: $e');
      Get.snackbar('Error', 'Gagal mengambil data pesanan hari ini');
    }

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

      final startTs = Timestamp.fromDate(start);
      final endTs = Timestamp.fromDate(end);

      try {
        final orders = await FirebaseFirestore.instance
            .collection('orders')
            .where('createdAt', isGreaterThanOrEqualTo: startTs)
            .where('createdAt', isLessThan: endTs)
            .get();

        debugPrint('DBG probe orders.length=${orders.docs.length}');
        chart.add({
          'day': '${start.day}/${start.month}',
          'total': orders.docs.length,
        });
      } catch (e) {
        debugPrint('DBG probe orders error -> $e');
      }
    }

    salesData.assignAll(chart);
  }
}
