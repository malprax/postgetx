import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true); // Auth Controller
    Get.put(DashboardController(), permanent: true); // Dashboard Controller
  }
}
