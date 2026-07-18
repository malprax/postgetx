import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/data/repositories/auth_repository.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/routes/app_routes.dart';
import 'package:postgetx/app/core/config/app_config.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = Get.find<LocalHiveRepository>();
  final currentUserModel = Rxn<UserModel>();
  final emailVerified = true.obs;
  final isUserModelLoaded = true.obs;
  final isPasswordVisible = false.obs;
  final emailController = TextEditingController(text: AppConfig.demoEmail);
  final passwordController =
      TextEditingController(text: AppConfig.demoPassword);
  final nameController = TextEditingController();

  Future<void> login() async {
    try {
      currentUserModel.value = await _repository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(Routes.dashboard);
    } catch (error) {
      Get.snackbar('Local demo login failed', error.toString());
    }
  }

  Future<void> loginAsDemo() async {
    emailController.text = AppConfig.demoEmail;
    passwordController.text = AppConfig.demoPassword;
    await login();
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUserModel.value = null;
    Get.offAllNamed(Routes.login);
  }

  Future<void> forgotPassword() async =>
      Get.snackbar('Offline demo', 'Use password demo123. No email is sent.');
  Future<void> sendVerificationEmail() async {}
  Future<void> reloadEmailStatus() async => emailVerified.value = true;
  Future<void> register({required String role}) async =>
      Get.snackbar('Offline demo', 'Account registration is disabled.');
}
