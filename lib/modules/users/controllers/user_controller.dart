import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../repositories/local_hive_repository.dart';

class UsersController extends GetxController {
  final repository = Get.find<LocalHiveRepository>();

  final userList = <UserModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;

    try {
      userList.assignAll(
        await repository.getUsers(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleStatus(UserModel user) async {
    await repository.saveUser(
      user.copyWith(
        isActive: !user.isActive,
        updatedAt: DateTime.now(),
      ),
    );

    await fetchUsers();
  }

  Future<void> deleteUser(String id) async {
    await repository.deleteUser(id);
    await fetchUsers();
  }
}
