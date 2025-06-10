// lib/modules/loyalty/views/loyalty_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loyalty_controller.dart';

class LoyaltyView extends StatelessWidget {
  final loyaltyC = Get.put(LoyaltyController());
  final customerC = TextEditingController();
  final pointsC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Loyalty Program')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerC,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: pointsC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Tambahkan Poin'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = customerC.text;
                final pts = int.tryParse(pointsC.text) ?? 0;
                if (name.isNotEmpty && pts > 0) {
                  loyaltyC.addPoints(name, pts);
                  customerC.clear();
                  pointsC.clear();
                }
              },
              child: Text('Tambah Poin'),
            ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView(
                    children: loyaltyC.customerPoints.entries.map((entry) {
                      return ListTile(
                        title: Text(entry.key),
                        subtitle: Text('Poin: ${entry.value}'),
                        trailing: IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => loyaltyC.resetPoints(entry.key),
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
