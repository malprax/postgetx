// lib/bindings/pos_binding.dart
import 'package:get/get.dart';
import '../modules/pos/controllers/pos_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosController>(() => PosController());
  }
}
