import 'package:get/get.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

class MenuController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();
  final menuItems = <MenuItemModel>[].obs;
  final categories = <CategoryModel>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMenuItems();
  }

  Future<void> fetchCategories() async =>
      categories.assignAll(await repository.getCategories());
  Future<void> fetchMenuItems() async =>
      menuItems.assignAll(await repository.getProducts());
  bool isDuplicate(String name, String categoryId, {String? excludeId}) =>
      menuItems.any((item) =>
          item.name.toLowerCase() == name.toLowerCase() &&
          item.categoryId == categoryId &&
          item.id != excludeId);
  Future<void> addMenuItem(String name, String categoryId,
      List<MenuVariant> variants, String? description) async {
    if (isDuplicate(name, categoryId)) return;
    final category = categories.firstWhere((c) => c.id == categoryId);
    menuItems.add(await repository.addProduct(
        name: name,
        categoryId: categoryId,
        categoryName: category.name,
        variants: variants,
        sku: 'MENU-${DateTime.now().microsecondsSinceEpoch}',
        stock: 0));
  }

  Future<void> updateMenuItem(MenuItemModel item) async {
    await repository.updateProduct(item);
    await fetchMenuItems();
  }

  Future<void> deleteMenuItem(String id) async {
    await repository.deleteProduct(id);
    await fetchMenuItems();
  }

  Future<void> saveMenu(MenuItemModel item) async {
    if (item.id.isEmpty) {
      await addMenuItem(
          item.name, item.categoryId, item.variants, item.description);
    } else {
      await updateMenuItem(item);
    }
  }
}
