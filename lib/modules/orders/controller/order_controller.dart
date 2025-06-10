// lib/modules/orders/controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderController extends GetxController {
  var orderList = <Map<String, dynamic>>[].obs;
  var filteredList = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'semua'.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    debounce(searchQuery, (_) => applyFilters(),
        time: Duration(milliseconds: 300));
    ever(selectedStatus, (_) => applyFilters());
  }

  void fetchOrders() async {
    final snapshot = await firestore.collection('orders').get();
    orderList.value =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    applyFilters();
  }

  void addOrder(String customer, String item, int quantity) async {
    final order = {
      'customer': customer,
      'item': item,
      'quantity': quantity,
      'status': 'diproses',
      'timestamp': FieldValue.serverTimestamp(),
    };
    await firestore.collection('orders').add(order);
    fetchOrders();
  }

  void updateStatus(int index, String status) async {
    final docSnapshot = await firestore
        .collection('orders')
        .where('customer', isEqualTo: orderList[index]['customer'])
        .where('item', isEqualTo: orderList[index]['item'])
        .limit(1)
        .get();

    if (docSnapshot.docs.isNotEmpty) {
      final docId = docSnapshot.docs.first.id;
      await firestore
          .collection('orders')
          .doc(docId)
          .update({'status': status});
      fetchOrders();
    }
  }

  void applyFilters() {
    filteredList.value = orderList.where((order) {
      final matchesSearch = order['customer']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          order['item']
              .toString()
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      final matchesStatus = selectedStatus.value == 'semua' ||
          order['status'] == selectedStatus.value;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }
}
