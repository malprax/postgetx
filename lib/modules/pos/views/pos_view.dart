// lib/modules/pos/views/pos_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  final posC = Get.put(PosController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Point of Sale')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text('Total Item: ${posC.itemCount.value}')),
            Obx(() => Text(
                'Total Harga: Rp ${posC.totalPrice.value.toStringAsFixed(2)}')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => posC.addItem(1 as RxInt, 25000 as RxInt),
              child: Text('Tambah Item (Rp 25.000)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => posC.reset(),
              child: Text('Reset Transaksi'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
