// lib/modules/tracking/controllers/tracking_controller.dart
import 'package:get/get.dart';

class TrackingController extends GetxController {
  var trackingList = <Map<String, dynamic>>[].obs;

  void updateTracking(String orderId, String status) {
    final index = trackingList.indexWhere((e) => e['orderId'] == orderId);
    if (index != -1) {
      trackingList[index]['status'] = status;
      trackingList.refresh();
    }
  }

  void addTracking(String orderId, String status) {
    trackingList.add({'orderId': orderId, 'status': status});
  }
}
