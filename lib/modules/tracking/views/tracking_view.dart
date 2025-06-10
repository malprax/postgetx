// lib/modules/tracking/views/tracking_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends StatelessWidget {
  final trackingC = Get.put(TrackingController());
  final orderIdC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pelacakan Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: orderIdC,
              decoration: InputDecoration(labelText: 'ID Pesanan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final id = orderIdC.text;
                if (id.isNotEmpty) {
                  trackingC.addTracking(id, 'dalam perjalanan');
                  orderIdC.clear();
                }
              },
              child: Text('Tambahkan Pelacakan'),
            ),
            Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: trackingC.trackingList.length,
                    itemBuilder: (context, index) {
                      final track = trackingC.trackingList[index];
                      return ListTile(
                        title: Text('Pesanan: ${track['orderId']}'),
                        subtitle: Text('Status: ${track['status']}'),
                        trailing: DropdownButton<String>(
                          value: track['status'],
                          onChanged: (val) {
                            if (val != null) {
                              trackingC.updateTracking(track['orderId'], val);
                            }
                          },
                          items: [
                            'dalam perjalanan',
                            'sudah sampai',
                            'gagal kirim'
                          ]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
