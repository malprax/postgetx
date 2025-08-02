// lib/modules/pos/views/pos_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosController());
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp');

    return Scaffold(
      appBar: AppBar(title: const Text('POS System')),
      body: Obx(() => Row(
            children: [
              // 📁 Kategori Sidebar
              Container(
                width: 180,
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kategori',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.categories
                          .map((category) => ChoiceChip(
                                label: Text(category),
                                selected: controller.selectedCategory.value ==
                                    category,
                                onSelected: (_) =>
                                    controller.setCategoryFilter(category),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // 🧾 Menu Grid
              Expanded(
                flex: 3,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.filteredMenu.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.filteredMenu[index];
                    return Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          for (var variant in item.variants)
                            ElevatedButton(
                              onPressed: () =>
                                  controller.addItem(item, variant.size),
                              child: Text(
                                  '${variant.size} - ${currencyFormat.format(variant.price)}'),
                            )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // 🛒 Ringkasan Order
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Order',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.cartItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text('${item.name} (${item.size})'),
                                subtitle: Text(
                                    '${item.quantity} x ${currencyFormat.format(item.price)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          controller.decreaseQuantity(item),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          controller.increaseQuantity(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          controller.removeItem(item),
                                    ),
                                  ],
                                ),
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
                          const Text('Diskon: '),
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
                          'Total: ${currencyFormat.format(controller.totalAfterDiscount.value)}'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.payment,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Jumlah Bayar'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.print),
                              label: const Text('Cetak Nota'),
                              onPressed: () => controller.printReceipt(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.payment),
                              label: const Text('Charge'),
                              onPressed: () async {
                                final paid =
                                    double.tryParse(controller.payment.text);
                                if (paid == null ||
                                    paid <
                                        controller.totalAfterDiscount.value) {
                                  Get.snackbar('Error', 'Pembayaran kurang');
                                  return;
                                }
                                await controller.checkout(); // reset cart
                                final change =
                                    paid - controller.totalAfterDiscount.value;

                                Get.defaultDialog(
                                  title: 'Sukses',
                                  content: Column(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 48),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Kembalian: ${currencyFormat.format(change)}')
                                    ],
                                  ),
                                  confirm: ElevatedButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('OK'),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
