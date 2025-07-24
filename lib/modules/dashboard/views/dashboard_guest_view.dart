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
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat datang, ${user?.name ?? 'Tamu'}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (!auth.emailVerified.value)
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
                              Get.snackbar('Error',
                                  'Gagal mengirim email verifikasi: $e');
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
                              Get.snackbar(
                                  'Sukses', 'Email sudah diverifikasi!');
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
                if (!auth.emailVerified.value)
                  const Text(
                    'Anda hanya bisa melihat menu. Untuk melakukan pemesanan, verifikasi akun terlebih dahulu.',
                    style: TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Informasi Umum Aplikasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selamat datang di sistem manajemen restoran. Anda bisa melihat menu dan promo aktif. Silakan verifikasi email untuk akses penuh.',
                ),
              ],
            ),
          )),
    );
  }
}
