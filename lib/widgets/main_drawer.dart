import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class MainDrawer extends StatelessWidget {
  MainDrawer({super.key});

  final auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUserModel.value;
    final role = user?.role ?? 'guest';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Guest'),
            accountEmail: Text(user?.email ?? 'Not Logged In'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: const AssetImage('assets/user_avatar.png'),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            decoration: const BoxDecoration(color: Colors.pink),
          ),

          // =======================
          // Admin & Staff
          // =======================
          if (user != null && (role == 'admin' || role == 'staff')) ...[
            _drawerTile(
              icon: Icons.dashboard,
              title: 'Dashboard',
              route: Routes.dashboard,
            ),
            _drawerTile(
              icon: Icons.store,
              title: 'POS',
              route: Routes.pos,
            ),
            _drawerTile(
              icon: Icons.inventory,
              title: 'Stock',
              route: Routes.stock,
            ),
            _drawerTile(
              icon: Icons.receipt,
              title: 'Orders',
              route: Routes.orders,
            ),
            _drawerTile(
              icon: Icons.category,
              title: 'Category',
              route: Routes.category,
            ),
          ],

          // =======================
          // Admin Only
          // =======================
          if (user != null && role == 'admin') ...[
            _drawerTile(
              icon: Icons.supervised_user_circle,
              title: 'User Management',
              route: Routes.users,
            ),
            _drawerTile(
              icon: Icons.receipt_long,
              title: 'Audit Logs',
              route: Routes.auditlogs,
            ),
          ],

          // =======================
          // Customer
          // =======================
          if (user != null && role == 'customer') ...[
            _drawerTile(
              icon: Icons.loyalty,
              title: 'Loyalty Program',
              route: Routes.loyalty,
            ),
            _drawerTile(
              icon: Icons.shopping_cart_checkout,
              title: 'Pre-Order',
              route: Routes.preorder,
            ),
            _drawerTile(
              icon: Icons.track_changes,
              title: 'Order Tracking',
              route: Routes.tracking,
            ),
          ],

          // =======================
          // Profile (semua login)
          // =======================
          if (user != null)
            _drawerTile(
              icon: Icons.person,
              title: 'My Profile',
              route: Routes.profile,
            ),

          // =======================
          // Logout (semua login)
          // =======================
          if (user != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await auth.logout();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Get.back(); // close drawer
        Get.toNamed(route);
      },
    );
  }
}
