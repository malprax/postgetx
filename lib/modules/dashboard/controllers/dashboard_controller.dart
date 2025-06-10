// lib/modules/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';

class DashboardController extends GetxController {
  var title = 'Dashboard'.obs;

  void updateTitle(String newTitle) {
    title.value = newTitle;
  }
}
