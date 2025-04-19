// modules/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/auth/controllers.dart/auth_controller.dart';

class DashboardPage extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Dashboard"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authController.logout();
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
