// lib/modules/dashboard/views/dashboard_menu.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/loyalty/views/loyalty_view.dart';
import 'package:postgetx/modules/orders/views/order_view.dart';
import 'package:postgetx/modules/preorder/views/preorder_view.dart';
import 'package:postgetx/modules/tracking/views/tracking_view.dart';

class DashboardMenu extends StatefulWidget {
  @override
  _DashboardMenuState createState() => _DashboardMenuState();
}

class _DashboardMenuState extends State<DashboardMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    OrderView(),
    TrackingView(),
    PreorderView(),
    LoyaltyView(),
  ];

  final List<String> _titles = ['Pesanan', 'Pelacakan', 'Pre-Order', 'Loyalty'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pesanan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping), label: 'Pelacakan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Pre-Order'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: 'Loyalty'),
        ],
      ),
    );
  }
}
