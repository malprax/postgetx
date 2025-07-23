// menu_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../models/menu_model.dart';

class MenuController extends GetxController {
  final menus = <MenuModel>[].obs;
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final basePriceController = TextEditingController();
  final sizes = <String>[].obs;
  final sizePrices = <String, double>{}.obs;
  final extras = <String>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchMenus() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('menus').get();
      final data = snapshot.docs.map((doc) {
        return MenuModel.fromMap(doc.id, doc.data());
      }).toList();

      menus.assignAll(data);
    } catch (e) {
      print("Error fetching menus: $e");
      Get.snackbar("Error", "Gagal mengambil data menu");
    }
  }

  Future<void> addMenu() async {
    final menu = MenuModel(
      id: '',
      name: nameController.text,
      category: categoryController.text,
      basePrice: double.tryParse(basePriceController.text) ?? 0,
      sizes: sizes,
      sizePrices: sizePrices,
      extras: extras,
      createdAt: Timestamp.now(),
    );
    await _firestore.collection('menus').add(menu.toMap());
    clearFields();
  }

  void clearFields() {
    nameController.clear();
    categoryController.clear();
    basePriceController.clear();
    sizes.clear();
    sizePrices.clear();
    extras.clear();
  }
}
