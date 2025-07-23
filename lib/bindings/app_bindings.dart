import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
  }
}
