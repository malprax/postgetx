// PREORDER CONTROLLER
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PreorderController extends GetxController {
  var preorderList = <Map<String, dynamic>>[].obs;
  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPreorders();
  }

  void fetchPreorders() async {
    final snapshot = await firestore.collection('preorders').get();
    preorderList.value =
        snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();
  }

  void addPreorder(String customer, String item, DateTime pickupDate) async {
    final order = {
      'customer': customer,
      'item': item,
      'pickupDate': pickupDate.toIso8601String(),
      'status': 'dipesan'
    };
    await firestore.collection('preorders').add(order);
    fetchPreorders();
  }

  void updateStatus(int index, String status) async {
    final order = preorderList[index];
    final docs = await firestore
        .collection('preorders')
        .where('customer', isEqualTo: order['customer'])
        .where('item', isEqualTo: order['item'])
        .limit(1)
        .get();
    if (docs.docs.isNotEmpty) {
      await firestore
          .collection('preorders')
          .doc(docs.docs.first.id)
          .update({'status': status});
      fetchPreorders();
    }
  }
}
