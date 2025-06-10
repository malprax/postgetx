// lib/modules/stock/views/stock_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stock_controller.dart';

class StockView extends StatelessWidget {
  final stockC = Get.put(StockController());
  final nameC = TextEditingController();
  final qtyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Stok')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameC,
              decoration: InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Jumlah'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = nameC.text;
                final qty = int.tryParse(qtyC.text) ?? 0;
                if (name.isNotEmpty && qty > 0) {
                  stockC.addStock(name, qty);
                  nameC.clear();
                  qtyC.clear();
                }
              },
              child: Text('Tambah ke Stok'),
            ),
            const Divider(height: 20),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: stockC.stockList.length,
                    itemBuilder: (context, index) {
                      final item = stockC.stockList[index];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: Text('Qty: ${item['qty']}'),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
