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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
              onPressed: () => _authController.loginWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}
