import 'package:get/get.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';

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
