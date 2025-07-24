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
      body: Obx(() => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Email: ${user?.email ?? ''}"),
              Text("Role: ${user?.role ?? ''}"),
              const SizedBox(height: 16),
              if (!auth.emailVerified.value) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Akun Anda belum diverifikasi.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Silakan cek email Anda dan klik tautan verifikasi untuk mengaktifkan akun.',
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await auth.sendVerificationEmail();
                            Get.snackbar('Terkirim',
                                'Email verifikasi berhasil dikirim ulang.');
                          } catch (e) {
                            Get.snackbar(
                                'Error', 'Gagal mengirim email verifikasi: $e');
                          }
                        },
                        icon: const Icon(Icons.email),
                        label: const Text('Kirim Ulang Email Verifikasi'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await auth.reloadEmailStatus();
                          if (auth.emailVerified.value) {
                            Get.snackbar('Sukses', 'Email sudah diverifikasi!');
                          } else {
                            Get.snackbar('Belum Diverifikasi',
                                'Email Anda belum diverifikasi.');
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Periksa Status Email'),
                      ),
                    ],
                  ),
                ),
              ],
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
          )),
    );
  }
}
