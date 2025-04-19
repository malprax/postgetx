// bindings/auth_binding.dart
import 'package:get/get.dart';
import '../modules/auth/controllers.dart/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
