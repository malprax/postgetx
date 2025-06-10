// lib/modules/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';

class DashboardView extends StatelessWidget {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authC.logout(),
          )
        ],
      ),
      body: Center(
        child: Text('Selamat datang di Retail Management System!'),
      ),
    );
  }
}
