// lib/modules/pos/views/pos_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/menu_item_model.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosController());
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp');
    final TextEditingController paidController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('POS System')),
      body: Obx(() => Column(
            children: [
              // Menu Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.menuItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.menuItems[index];
                    return Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          for (var entry in item.prices.entries)
                            ElevatedButton(
                              onPressed: () =>
                                  controller.addItem(item, entry.key),
                              child: Text(
                                  '${entry.key} - ${currencyFormat.format(entry.value)}'),
                            )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Cart Summary
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cart Items',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.cartItems[index];
                            return ListTile(
                              title: Text('${item.name} (${item.size})'),
                              subtitle: Text(
                                  '${item.quantity} x ${currencyFormat.format(item.price)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => controller.removeItem(item),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Subtotal: ${currencyFormat.format(controller.totalAmount.value)}'),
                      Row(
                        children: [
                          const Text('Discount: '),
                          DropdownButton<double>(
                            value: controller.discount.value,
                            items: const [0, 5, 10, 15, 20]
                                .map((e) => DropdownMenuItem(
                                    value: e.toDouble(), child: Text('$e%')))
                                .toList(),
                            onChanged: (val) =>
                                controller.setDiscount(val ?? 0),
                          ),
                        ],
                      ),
                      Text(
                          'Total After Discount: ${currencyFormat.format(controller.totalAfterDiscount.value)}'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: paidController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Amount Paid'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Charge'),
                          onPressed: () async {
                            final paid = double.tryParse(paidController.text);
                            if (paid == null ||
                                paid < controller.totalAfterDiscount.value) {
                              Get.snackbar('Error', 'Insufficient payment');
                              return;
                            }
                            final change =
                                paid - controller.totalAfterDiscount.value;
                            await controller.checkout();
                            Get.defaultDialog(
                              title: 'Success',
                              content: Column(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Change: ${currencyFormat.format(change)}')
                                ],
                              ),
                              confirm: ElevatedButton(
                                onPressed: () => Get.back(),
                                child: const Text('OK'),
                              ),
                            );
                            paidController.clear();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
