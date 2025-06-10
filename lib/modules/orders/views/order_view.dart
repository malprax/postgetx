// lib/modules/orders/views/order_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/orders/controller/order_controller.dart';

class OrderView extends StatelessWidget {
  final orderC = Get.put(OrderController());
  final customerC = TextEditingController();
  final itemC = TextEditingController();
  final qtyC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Pesanan')),
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
            TextField(
              controller: qtyC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Jumlah'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final customer = customerC.text;
                final item = itemC.text;
                final qty = int.tryParse(qtyC.text) ?? 0;
                if (customer.isNotEmpty && item.isNotEmpty && qty > 0) {
                  orderC.addOrder(customer, item, qty);
                  customerC.clear();
                  itemC.clear();
                  qtyC.clear();
                }
              },
              child: Text('Tambah Pesanan'),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => orderC.setSearchQuery(value),
                    decoration: InputDecoration(
                        hintText: 'Cari pelanggan atau item...'),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: orderC.selectedStatus.value,
                  onChanged: (val) {
                    if (val != null) orderC.setSelectedStatus(val);
                  },
                  items: ['semua', 'diproses', 'dikirim', 'selesai']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: orderC.filteredList.length,
                    itemBuilder: (context, index) {
                      final order = orderC.filteredList[index];
                      return ListTile(
                        title: Text('${order['customer']} - ${order['item']}'),
                        subtitle: Text('Jumlah: ${order['quantity']}'),
                        trailing: DropdownButton<String>(
                          value: order['status'],
                          onChanged: (val) {
                            if (val != null) {
                              orderC.updateStatus(index, val);
                            }
                          },
                          items: ['diproses', 'dikirim', 'selesai']
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
