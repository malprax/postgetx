import 'package:get/get.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';

class OrderController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();
  final orderList = <Map<String, dynamic>>[].obs;
  final filteredList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedStatus = 'semua'.obs;
  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    debounce(searchQuery, (_) => applyFilters(),
        time: const Duration(milliseconds: 300));
    ever(selectedStatus, (_) => applyFilters());
  }

  Future<void> fetchOrders() async {
    final transactions = await repository.getTransactions();
    orderList.assignAll(transactions.map((o) => {
          'customer': o.createdBy,
          'item': o.items.map((i) => i.name).join(', '),
          'quantity': o.items.fold<int>(0, (s, i) => s + i.quantity),
          'status': 'selesai'
        }));
    applyFilters();
  }

  Future<void> addOrder(String customer, String item, int quantity) async =>
      Get.snackbar('Offline demo', 'Create orders from the POS screen.');
  void updateStatus(int index, String status) {
    orderList[index]['status'] = status;
    orderList.refresh();
    applyFilters();
  }

  void applyFilters() {
    final q = searchQuery.value.toLowerCase();
    filteredList.assignAll(orderList.where((o) =>
        (o['customer'].toString().toLowerCase().contains(q) ||
            o['item'].toString().toLowerCase().contains(q)) &&
        (selectedStatus.value == 'semua' ||
            o['status'] == selectedStatus.value)));
  }

  void setSearchQuery(String value) => searchQuery.value = value;
  void setSelectedStatus(String value) => selectedStatus.value = value;
}
