// lib/modules/pos/views/pos_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/models/menu_variant.dart';
import '../controllers/pos_controller.dart';

class PosView extends StatelessWidget {
  final PosController controller = Get.find();

  PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Point Of Sale"),
        actions: [
          Tooltip(
            message: 'Riwayat Transaksi',
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Get.toNamed('/order-history'),
            ),
          ),
          Tooltip(
            message: 'Migrasi Data',
            child: IconButton(
              icon: const Icon(Icons.system_update_alt),
              onPressed: () =>
                  Get.find<PosController>().migrateMenuCategoryId(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Menu Grid dan kategori di atas
          Expanded(
            child: Row(
              children: [
                // Sidebar kategori
                Obx(() {
                  return Container(
                    width: 150,
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              final isSelected =
                                  controller.selectedCategory.value?.id ==
                                      category.id;

                              return ListTile(
                                title: Text(category.name),
                                selected: isSelected,
                                onTap: () =>
                                    controller.setCategoryFilter(category),
                              );
                            },
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: controller.showAddCategoryDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Kategori'),
                        ),
                      ],
                    ),
                  );
                }),

                // Daftar menu
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final menus = controller.filteredMenu;
                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 4 / 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        final menu = menus[index];

                        final defaultVariant = menu.variants.isNotEmpty
                            ? menu.variants.first
                            : MenuVariant(size: 'default', price: 0);

                        return Card(
                          elevation: 3,
                          child: InkWell(
                            onTap: () {
                              controller.addItem(menu, defaultVariant.size);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((menu.imageUrl ?? '').isNotEmpty)
                                    Center(
                                      child: Image.network(
                                        menu.imageUrl ?? '',
                                        height: 60,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          menu.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            controller.showEditMenuDialog(menu);
                                          } else if (value == 'delete') {
                                            controller.deleteMenu(menu);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit')),
                                          PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Hapus')),
                                        ],
                                        icon: const Icon(Icons.more_vert,
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${defaultVariant.price.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Keranjang
                Expanded(
                  child: Obx(() {
                    return Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keranjang',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = controller.cartItems[index];
                                return ListTile(
                                  title: Text('${item.name} (${item.size})'),
                                  subtitle: Text(
                                      'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            controller.decreaseQuantity(item),
                                        icon: const Icon(Icons.remove),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            controller.increaseQuantity(item),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          TextField(
                            controller: controller.payment,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dibayar',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => controller.recalculateTotal(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                              'Total: Rp ${controller.totalAmount.value.toStringAsFixed(0)}'),
                          Text(
                              'Diskon: ${controller.discount.value.toStringAsFixed(0)}%'),
                          Text(
                              'Grand Total: Rp ${controller.totalAfterDiscount.value.toStringAsFixed(0)}'),
                          Obx(() {
                            if (controller.isPaymentEmpty.value) {
                              return const Text(
                                'Belum dibayar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              );
                            } else if (!controller.isPaymentSufficient.value) {
                              return const Text(
                                'Pembayaran kurang!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return Text(
                                'Kembalian: Rp ${controller.totalChange.value.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            }
                          }),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Obx(() => ElevatedButton.icon(
                                      onPressed: controller
                                              .isPaymentSufficient.value
                                          ? controller.checkoutAndPrint
                                          : null, // 🔒 disable jika uang kurang
                                      icon: const Icon(Icons.print),
                                      label: const Text('Checkout & Cetak'),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
          ),

          // Tombol Tambah Menu di tengah bawah
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.showAddMenuDialog();
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text("Menu"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
