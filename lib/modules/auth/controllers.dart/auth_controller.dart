import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgetx/routes/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var user = Rx<User?>(null);

  @override
  void onInit() {
    user.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar("Registration Failed", e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
