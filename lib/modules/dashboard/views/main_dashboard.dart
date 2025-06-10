// lib/modules/dashboard/views/main_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/orders/views/order_view.dart';
import '../../../modules/tracking/views/tracking_view.dart';
import '../../../modules/preorder/views/preorder_view.dart';
import '../../../modules/loyalty/views/loyalty_view.dart';

class MainDashboardPage extends StatefulWidget {
  @override
  _MainDashboardPageState createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  Widget currentPage = OrderView();
  String pageTitle = 'Point of Sales';

  void switchPage(String title, Widget page) {
    setState(() {
      pageTitle = title;
      currentPage = page;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Jelly Grande'),
              accountEmail: Text('Cashier'),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: Icon(Icons.point_of_sale),
              title: Text('Point of Sales'),
              onTap: () => switchPage('Point of Sales', OrderView()),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('Tracking'),
              onTap: () => switchPage('Tracking', TrackingView()),
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Pre-Order'),
              onTap: () => switchPage('Pre-Order', PreorderView()),
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('Loyalty Program'),
              onTap: () => switchPage('Loyalty Program', LoyaltyView()),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => Get.offAllNamed('/login'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentPage,
      ),
    );
  }
}
