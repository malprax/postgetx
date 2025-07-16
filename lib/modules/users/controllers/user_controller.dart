import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class UsersController extends GetxController {
  final userService = UserService();
  final RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    fetchUsers();
    super.onInit();
  }

  Future<void> fetchUsers() async {
    final users = await userService.getAllUsers();
    userList.assignAll(users);
  }

  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    fetchUsers();
  }

  Future<void> toggleStatus(UserModel user) async {
    await userService.setUserActive(user.uid, !user.isActive);
    fetchUsers();
  }
}
