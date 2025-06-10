// lib/modules/preorder/views/preorder_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/preorder_controller.dart';

class PreorderView extends StatelessWidget {
  final preorderC = Get.put(PreorderController());
  final customerC = TextEditingController();
  final itemC = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pre-Order Barang')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: customerC,
              decoration: InputDecoration(labelText: 'Nama Pelanggan'),
            ),
            TextField(
              controller: itemC,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              child: Text('Pilih Tanggal Pengambilan'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (customerC.text.isNotEmpty && itemC.text.isNotEmpty && selectedDate != null) {
                  preorderC.addPreorder(customerC.text, itemC.text, selectedDate!);
                  customerC.clear();
                  itemC.clear();
                  selectedDate = null;
                }
              },
              child: Text('Simpan Pre-Order'),
            ),
            const Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: preorderC.preorderList.length,
                    itemBuilder: (context, index) {
                      final order = preorderC.preorderList[index];
                      return ListTile(
                        title: Text('${order['customer']} - ${order['item']}'),
                        subtitle: Text('Ambil: ${order['pickupDate'].toString().split(' ')[0]}'),
                        trailing: DropdownButton<String>(
                          value: order['status'],
                          onChanged: (val) {
                            if (val != null) preorderC.updateStatus(index, val);
                          },
                          items: ['dipesan', 'siap diambil', 'selesai']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
