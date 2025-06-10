// lib/modules/loyalty/controllers/loyalty_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyController extends GetxController {
  var customerPoints = <String, int>{}.obs;
  final firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchPoints();
  }

  void fetchPoints() async {
    final snapshot = await firestore.collection('loyalty').get();
    for (var doc in snapshot.docs) {
      customerPoints[doc.id] = doc['points'];
    }
  }

  void addPoints(String customer, int points) async {
    final existing = customerPoints[customer] ?? 0;
    final newTotal = existing + points;
    customerPoints[customer] = newTotal;
    await firestore
        .collection('loyalty')
        .doc(customer)
        .set({'points': newTotal});
  }

  void resetPoints(String customer) async {
    customerPoints[customer] = 0;
    await firestore.collection('loyalty').doc(customer).set({'points': 0});
  }
}
