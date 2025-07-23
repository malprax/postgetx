// ===========================
// 📍 DASHBOARD GUEST VIEW
// ===========================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardGuestView extends StatelessWidget {
  const DashboardGuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selamat Datang di Resto Ayam Rempah"),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/register'),
            child: const Text("Daftar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Promosi
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/banner_promo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text("Menu Favorit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Produk Populer (dummy)
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/ayam_goreng.png', height: 80),
                        const SizedBox(height: 8),
                        const Text("Ayam Goreng",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text("Rp25.000"),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),
            const Text("Silakan login atau daftar untuk melakukan pemesanan",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
