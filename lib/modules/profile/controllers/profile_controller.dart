import 'package:get/get.dart';
import 'package:postgetx/services/auth_service.dart';
import 'package:postgetx/services/storage_service.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthController>();
  final userService = UserService();
  final storageService = StorageService();

  final authService = AuthService();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    user.value = auth.currentUserModel.value;
    super.onInit();
  }

  Future<void> updateName(String newName) async {
    isLoading.value = true;

    final updated = user.value!.copyWith(name: newName);
    await userService.saveUser(updated);

    user.value = updated;
    auth.currentUserModel.value = updated;

    isLoading.value = false;
    Get.snackbar('Berhasil', 'Nama berhasil diperbarui');
  }

  Future<void> sendResetPassword(String email) async {
    try {
      await authService.sendPasswordReset(email);
      Get.snackbar("Berhasil", "Link ganti password dikirim ke $email");
    } catch (e) {
      Get.snackbar("Gagal", e.toString());
    }
  }

  Future<void> uploadProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final url = await storageService.uploadUserPhoto(
        File(picked.path), user.value!.uid);

    final updated = user.value!.copyWith(photoUrl: url);
    await userService.saveUser(updated);
    user.value = updated;
    auth.currentUserModel.value = updated;

    Get.snackbar("Berhasil", "Foto profil diperbarui");
  }
}
