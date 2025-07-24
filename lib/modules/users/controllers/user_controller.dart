// lib/modules/users/controllers/user_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';

class UsersController extends GetxController {
  final userList = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data());
      }).toList();

      userList.assignAll(users);
    } catch (e) {
      print("[UsersController] Error fetching users: $e");
      Get.snackbar("Gagal Memuat Pengguna",
          "Pastikan Anda memiliki izin sebagai admin.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'isActive': !user.isActive,
      });
      fetchUsers();
    } catch (e) {
      Get.snackbar("Error", "Gagal mengubah status: $e");
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      fetchUsers();
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus pengguna: $e");
    }
  }
}
