import 'package:get/get.dart';
import '../../../models/order_model.dart';
import '../../../repositories/local_hive_repository.dart';

class OrderHistoryController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();
  final orders = <OrderModel>[].obs;
  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  Future<void> fetchOrders() async =>
      orders.assignAll(await repository.getTransactions());
}
