import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Obx(() {
          if (_authController.isLoading.value) {
            return CircularProgressIndicator();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _authController.loginWithGoogle(),
                icon: Icon(Icons.email),
                label: Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Get.offNamed('/register');
                },
                child: Text('Don’t have an account? Register here'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
