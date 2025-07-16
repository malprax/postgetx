import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class AuthController extends GetxController {
  final authService = AuthService();
  final userService = UserService();

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();

  @override
  void onInit() {
    firebaseUser.bindStream(authService.authStateChanges);
    ever(firebaseUser, _handleUserChanged);
    super.onInit();
  }

  Future<void> _handleUserChanged(User? user) async {
    if (user != null) {
      final userData = await userService.getUserByUid(user.uid);
      if (userData != null) {
        currentUserModel.value = userData;
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await authService.signIn(email, password);
      if (user != null) Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Login Gagal', e.toString());
    }
  }

  Future<void> register(
      String name, String email, String password, String role) async {
    try {
      final user = await authService.register(email, password);
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: name,
          role: role,
          isActive: true,
          createdAt: DateTime.now(),
        );
        await userService.saveUser(newUser);
        currentUserModel.value = newUser;
        Get.offAllNamed('/dashboard');
      }
    } catch (e) {
      Get.snackbar('Registrasi Gagal', e.toString());
    }
  }

  Future<void> logout() async {
    await authService.signOut();
    currentUserModel.value = null;
    Get.offAllNamed('/login');
  }

  bool get isLoggedIn => firebaseUser.value != null;
}
