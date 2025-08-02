import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';

class EmailVerificationBanner extends StatelessWidget {
  final AuthController auth = Get.find<AuthController>();

  EmailVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Hanya tampilkan jika belum verifikasi dan BUKAN guest
      final user = auth.currentUserModel.value;
      final isGuest = (user?.role ?? 'guest') == 'guest';
      if (auth.emailVerified.value || isGuest) return const SizedBox();

      return Container(
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
                  fontWeight: FontWeight.bold, color: Colors.deepOrange),
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
                  Get.snackbar(
                      'Terkirim', 'Email verifikasi berhasil dikirim ulang.');
                } catch (e) {
                  Get.snackbar('Error', 'Gagal mengirim email verifikasi: $e');
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
                  Get.snackbar(
                      'Belum Diverifikasi', 'Email Anda belum diverifikasi.');
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Periksa Status Email'),
            ),
          ],
        ),
      );
    });
  }
}
