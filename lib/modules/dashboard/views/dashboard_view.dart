import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/register_view.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/sales_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final dashboard = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final user = auth.currentUserModel.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user.role != 'admin') {
          return Center(
            child: Text(
              'Akses Ditolak: Halaman ini hanya untuk Admin.',
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
            ),
          );
        }

        // 🔔 Notifikasi stok kritis (sekali tampil)
        if (dashboard.lowStockCount.value > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              'Stok Kritis',
              'Ada ${dashboard.lowStockCount.value} produk yang hampir habis!',
              backgroundColor: Colors.red[100],
              colorText: Colors.red[900],
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Header
              Text('Halo, ${user.name}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Email: ${user.email}',
                  style: const TextStyle(fontSize: 16)),
              Text('Role: ${user.role}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),

              // 📊 Statistik Ringkas
              DashboardSummaryCard(
                title: 'Pesanan Hari Ini',
                value: dashboard.ordersToday.value,
                icon: Icons.receipt_long,
                color: Colors.orange,
              ),
              DashboardSummaryCard(
                title: 'Stok Rendah',
                value: dashboard.lowStockCount.value,
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              DashboardSummaryCard(
                title: 'Pelanggan Aktif',
                value: dashboard.activeCustomers.value,
                icon: Icons.people,
                color: Colors.green,
              ),
              const SizedBox(height: 24),

              // 📈 Grafik Penjualan
              const Text(
                'Grafik Penjualan (7 Hari Terakhir)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SalesChart(data: dashboard.salesData),

              const SizedBox(height: 32),
              const Divider(),

              // 🛠️ Aksi Admin
              ElevatedButton.icon(
                icon: const Icon(Icons.supervised_user_circle),
                label: const Text('Manajemen Pengguna'),
                onPressed: () => Get.toNamed('/users'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Tambah Akun Baru'),
                onPressed: () =>
                    Get.to(() => const RegisterView(enableRoleSelection: true)),
              ),
              const SizedBox(
                height: 12,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Profil Saya'),
                onPressed: () => Get.toNamed('/profile'),
              ),
              const SizedBox(height: 32),
              const Divider(),

              const Text(
                'Menu Statistik & Akses Modul (Opsional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 10,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.storefront),
                    label: const Text('POS'),
                    onPressed: () => Get.toNamed('/pos'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.inventory),
                    label: const Text('Stok'),
                    onPressed: () => Get.toNamed('/stock'),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.receipt),
                    label: const Text('Pesanan'),
                    onPressed: () => Get.toNamed('/orders'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
