// modules/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/auth/controllers.dart/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authController.register(
                    emailController.text, passwordController.text);
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
