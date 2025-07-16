// lib/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}
