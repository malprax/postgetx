// lib/modules/dashboard/views/dashboard_guest_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../../widgets/main_drawer.dart';

class DashboardGuestView extends StatelessWidget {
  const DashboardGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUserModel.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Dashboard"),
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang, ${user?.name ?? 'Tamu'} 👋',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            const Text(
              '🔒 Anda sedang dalam mode Tamu (Guest).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            const Text(
              'Sebagai tamu, Anda dapat melihat informasi menu dan promo yang tersedia. '
              'Untuk melakukan pemesanan, silakan daftar dan verifikasi email Anda.',
            ),
            const SizedBox(height: 24),

            const Text(
              '📋 Fitur Tersedia:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Lihat Menu & Kategori'),
              subtitle:
                  const Text('Akses ke daftar makanan & kategori tersedia'),
              onTap: () => Get.toNamed('/menu'),
            ),

            const Divider(height: 32),

            const Text(
              '📢 Info Tambahan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daftar akun untuk menikmati fitur lengkap seperti pemesanan makanan, tracking order, dan loyalty point.',
            ),

            const SizedBox(height: 24),

            // 🔐 Tombol Login & Register
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                    onPressed: () => Get.toNamed('/login'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Register'),
                    onPressed: () => Get.toNamed('/register'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
