// ================================
// 📍 DASHBOARD CUSTOMER VIEW
// ================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardCustomerView extends StatelessWidget {
  const DashboardCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUserModel.value;

    return Scaffold(
      appBar: AppBar(
        title: Text("Halo, ${user?.name ?? ''}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Email: ${user?.email ?? ''}"),
          Text("Role: ${user?.role ?? ''}"),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Riwayat Order Saya'),
            onPressed: () => Get.toNamed('/order-history'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Loyalty Point'),
            onPressed: () => Get.toNamed('/loyalty'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.location_pin),
            label: const Text('Tracking Order'),
            onPressed: () => Get.toNamed('/tracking'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('Profil Saya'),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
    );
  }
}
