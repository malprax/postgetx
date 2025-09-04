// lib/modules/menu/controllers/menu_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/menu_variant.dart';
import '../../../models/category_model.dart';

class MenuController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final RxList<MenuItemModel> menuItems = <MenuItemModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMenuItems();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await firestore.collection('categories').get();
      final items = snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
          .toList();
      categories.assignAll(items);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      final snapshot = await firestore.collection('menus').get();
      final items = snapshot.docs.map((doc) {
        return MenuItemModel.fromMap(doc.id, doc.data());
      }).toList();
      menuItems.assignAll(items);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch menu items: $e');
    }
  }

  bool isDuplicate(String name, String categoryId, {String? excludeId}) {
    return menuItems.any((item) =>
        item.name.toLowerCase() == name.toLowerCase() &&
        item.categoryId == categoryId &&
        item.id != excludeId);
  }

  Future<void> addMenuItem(
    String name,
    String categoryId,
    List<MenuVariant> variants,
    String? description,
    String? imageUrl,
  ) async {
    if (isDuplicate(name, categoryId)) {
      Get.snackbar('Duplicate', 'Menu item already exists in this category');
      return;
    }

    final newItem = MenuItemModel(
      id: '',
      name: name,
      categoryId: categoryId,
      variants: variants,
      description: description,
      imageUrl: imageUrl,
    );

    try {
      final doc = await firestore.collection('menus').add(newItem.toMap());
      final added = newItem.copyWith(id: doc.id);
      menuItems.add(added);
      Get.snackbar('Success', 'Menu item added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add menu item: $e');
    }
  }

  Future<void> updateMenuItem(MenuItemModel updatedItem) async {
    if (isDuplicate(updatedItem.name, updatedItem.categoryId,
        excludeId: updatedItem.id)) {
      Get.snackbar('Duplicate', 'Menu item already exists in this category');
      return;
    }

    try {
      await firestore
          .collection('menus')
          .doc(updatedItem.id)
          .set(updatedItem.toMap());

      final index =
          menuItems.indexWhere((element) => element.id == updatedItem.id);
      if (index != -1) {
        menuItems[index] = updatedItem;
      }

      Get.snackbar('Success', 'Menu item updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update menu: $e');
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await firestore.collection('menus').doc(id).delete();
      menuItems.removeWhere((item) => item.id == id);
      Get.snackbar('Success', 'Menu item deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete menu item: $e');
    }
  }

  Future<void> saveMenu(MenuItemModel item) async {
    if (item.id.isEmpty) {
      await addMenuItem(
        item.name,
        item.categoryId,
        item.variants,
        item.description,
        item.imageUrl,
      );
    } else {
      await updateMenuItem(item);
    }
    await fetchMenuItems(); // Refresh list
  }
}
