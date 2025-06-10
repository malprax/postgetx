// lib/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailC,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passC,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            Obx(() => authC.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => authC.login(emailC.text, passC.text),
                    child: Text('Login'),
                  )),
            TextButton(
              onPressed: () => Get.toNamed(Routes.REGISTER),
              child: Text('Belum punya akun? Daftar'),
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: () => authC.loginWithGoogle(),
              icon: Icon(Icons.g_mobiledata),
              label: Text('Login dengan Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
