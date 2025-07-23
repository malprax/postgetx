// dashboard_staff_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardStaffView extends StatelessWidget {
  const DashboardStaffView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUserModel.value;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Hello Staff, ${user?.name ?? ''}',
            style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
