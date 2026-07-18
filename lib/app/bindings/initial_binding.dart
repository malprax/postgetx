import 'package:get/get.dart';

import '../../repositories/local_hive_repository.dart';
import '../../repositories/pos_repository.dart';
import '../../services/print_service.dart';
import '../../services/printer_service.dart';
import '../modules/workspace/controllers/workspace_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosRepository>(() => Get.find<LocalHiveRepository>(),
        fenix: true);
    Get.lazyPut<PrinterService>(PrintService.new, fenix: true);
    Get.lazyPut(
        () => WorkspaceController(
            Get.find<PosRepository>(), Get.find<PrinterService>()),
        fenix: true);
  }
}
