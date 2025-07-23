import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/tracking_log_model.dart';

class TrackingLogController extends GetxController {
  final logs = <TrackingLogModel>[].obs;
  final isLoading = false.obs;

  Future<void> fetchLogs(String trackingId) async {
    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tracking_logs')
          .where('trackingId', isEqualTo: trackingId)
          .orderBy('timestamp', descending: true)
          .get();

      logs.value = snapshot.docs
          .map((doc) => TrackingLogModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat histori tracking");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Method untuk grafik log per hari
  Map<String, int> getLogCountPerDay() {
    final Map<String, int> result = {};
    for (var log in logs) {
      final date = DateFormat('yyyy-MM-dd').format(log.timestamp);
      result[date] = (result[date] ?? 0) + 1;
    }
    return result;
  }

  Future<void> exportLogsToExcel() async {
    // Implementasikan seperti export_service.dart
    // Panggil dari UI
  }
}
