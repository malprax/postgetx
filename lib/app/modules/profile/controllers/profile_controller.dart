import 'package:get/get.dart';

import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  final repository = Get.find<LocalHiveRepository>();

  final user = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = auth.currentUserModel.value;
  }

  Future<void> updateName(String name) async {
    final current = user.value;

    if (current == null) {
      return;
    }

    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      Get.snackbar(
        'Nama tidak valid',
        'Nama pengguna wajib diisi.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final updated = current.copyWith(
        name: trimmedName,
        updatedAt: DateTime.now(),
      );

      await repository.saveUser(updated);

      user.value = updated;
      auth.currentUserModel.value = updated;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendResetPassword(String email) async {
    Get.snackbar(
      'Offline demo',
      'Passwords are local; use demo123.',
    );
  }

  Future<void> uploadProfilePicture() async {
    Get.snackbar(
      'Offline demo',
      'Profile photo upload is disabled.',
    );
  }
}
