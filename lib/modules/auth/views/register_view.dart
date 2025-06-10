// lib/modules/auth/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends StatelessWidget {
  final authC = Get.find<AuthController>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
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
                    onPressed: () => authC.register(emailC.text, passC.text),
                    child: Text('Daftar'),
                  )),
            TextButton(
              onPressed: () => Get.offNamed(Routes.LOGIN),
              child: Text('Sudah punya akun? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
