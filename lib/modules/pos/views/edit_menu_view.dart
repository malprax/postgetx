import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/menu_variant.dart';
import '../controllers/pos_controller.dart';

class EditMenuView extends StatelessWidget {
  final MenuItemModel menu;

  EditMenuView({super.key, required this.menu});

  final TextEditingController nameController = TextEditingController();
  final List<TextEditingController> variantSizeControllers = [];
  final List<TextEditingController> variantPriceControllers = [];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();

    nameController.text = menu.name;

    // Inisialisasi controller untuk setiap variant
    for (var variant in menu.variants) {
      variantSizeControllers.add(TextEditingController(text: variant.size));
      variantPriceControllers
          .add(TextEditingController(text: variant.price.toStringAsFixed(0)));
    }

    return AlertDialog(
      title: const Text("Edit Menu"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama Menu"),
            ),
            const SizedBox(height: 8),
            const Text("Variants",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(menu.variants.length, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: variantSizeControllers[index],
                      decoration: const InputDecoration(labelText: "Size"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: variantPriceControllers[index],
                      decoration: const InputDecoration(labelText: "Harga"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              Get.snackbar('Gagal', 'Nama menu tidak boleh kosong');
              return;
            }

            List<MenuVariant> updatedVariants = [];

            for (int i = 0; i < variantSizeControllers.length; i++) {
              final size = variantSizeControllers[i].text.trim();
              final price =
                  double.tryParse(variantPriceControllers[i].text.trim()) ?? 0;

              if (size.isEmpty || price <= 0) {
                Get.snackbar(
                    'Gagal', 'Semua variant harus punya size dan harga > 0');
                return;
              }

              updatedVariants.add(MenuVariant(size: size, price: price));
            }

            await controller.editMenu(
              menu.id,
              menu.name,
              updatedVariants,
            );

            Get.back(); // Tutup dialog jika berhasil
          },
          child: const Text("Simpan"),
        )
      ],
    );
  }
}
