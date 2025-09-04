// lib/modules/category/controllers/category_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/category_model.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  void fetchCategories() async {
    final snapshot = await firestore.collection('categories').get();
    final list = snapshot.docs.map((doc) {
      print("Found category: ${doc.data()}"); // ⬅️ Tambahkan log ini
      return CategoryModel.fromMap(doc.id, doc.data());
    }).toList();
    categories.assignAll(list);
  }

  Future<void> addCategory(String name) async {
    if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar("Kategori Duplikat", "Nama kategori sudah ada");
      return;
    }

    final docRef = await firestore.collection('categories').add({'name': name});
    categories.add(CategoryModel(id: docRef.id, name: name));
    Get.snackbar("Berhasil", "Kategori ditambahkan");
  }

  Future<void> updateCategory(String id, String newName) async {
    if (newName.trim().isEmpty) {
      Get.snackbar("Gagal", "Nama kategori tidak boleh kosong");
      return;
    }

    await firestore.collection('categories').doc(id).update({'name': newName});
    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index] = CategoryModel(id: id, name: newName);
      categories.refresh();
    }
    Get.snackbar("Berhasil", "Kategori diperbarui");
  }

  Future<void> deleteCategory(String id) async {
    await firestore.collection('categories').doc(id).delete();
    categories.removeWhere((c) => c.id == id);
    Get.snackbar("Berhasil", "Kategori dihapus");
  }
}
