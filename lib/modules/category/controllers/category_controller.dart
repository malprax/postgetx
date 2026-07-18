import 'package:get/get.dart';
import '../../../models/category_model.dart';
import '../../../repositories/local_hive_repository.dart';

class CategoryController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();
  final categories = <CategoryModel>[].obs;
  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  Future<void> fetchCategories() async =>
      categories.assignAll(await repository.getCategories());
  Future<void> addCategory(String name) async {
    if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar('Duplicate', 'Category already exists');
      return;
    }
    categories.add(await repository.addCategory(name));
  }

  Future<void> updateCategory(String id, String name) async {
    await repository.updateCategory(id, name);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await repository.deleteCategory(id);
    await fetchCategories();
  }
}
