import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../views/dashboard/menu_view.dart';
import '../../views/dashboard/order_view.dart';
import '../../views/dashboard/profile_view.dart';

class DashboardView extends StatelessWidget {
  final DashboardController _dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_dashboardController
            .pageTitles[_dashboardController.currentIndex.value])),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _dashboardController.logout,
          ),
        ],
      ),
      body: Obx(() {
        // Switch between pages based on the current index
        switch (_dashboardController.currentIndex.value) {
          case 0:
            return MenuView();
          case 1:
            return OrderView();
          case 2:
            return ProfileView();
          default:
            return Center(child: Text('Page Not Found'));
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: _dashboardController.currentIndex.value,
          onTap: (index) => _dashboardController.updateIndex(index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      }),
    );
  }
}
