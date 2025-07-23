import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/category_model.dart';

class CategoryController extends GetxController {
  final categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    categories.value = snapshot.docs.map((doc) {
      return CategoryModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> addCategory(String name) async {
    final doc = await FirebaseFirestore.instance
        .collection('categories')
        .add({'name': name});
    categories.add(CategoryModel(id: doc.id, name: name));
  }

  Future<void> deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection('categories').doc(id).delete();
    categories.removeWhere((cat) => cat.id == id);
  }

  Future<void> updateCategory(String id, String newName) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(id)
        .update({'name': newName});
    final index = categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      categories[index] = CategoryModel(id: id, name: newName);
    }
  }
}
