import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/menu_item_model.dart';

class MenuController extends GetxController {
  final RxList<MenuItemModel> menuItems = <MenuItemModel>[].obs;
  final menuCollection = FirebaseFirestore.instance.collection('menu_items');

  @override
  void onInit() {
    super.onInit();
    fetchMenuItems();
  }

  void fetchMenuItems() {
    menuCollection.snapshots().listen((snapshot) {
      menuItems.value = snapshot.docs
          .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addMenuItem(MenuItemModel menu) async {
    await menuCollection.add(menu.toMap());
  }

  Future<void> updateMenuItem(String id, MenuItemModel updated) async {
    await menuCollection.doc(id).update(updated.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await menuCollection.doc(id).delete();
  }
}
