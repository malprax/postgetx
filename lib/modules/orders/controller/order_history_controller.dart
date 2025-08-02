import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/order_model.dart';

class OrderHistoryController extends GetxController {
  final orders = <OrderModel>[].obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  void fetchOrders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    orders.assignAll(snapshot.docs.map((e) => OrderModel.fromMap({
          'id': e.id,
          ...e.data(),
        })));
  }
}
