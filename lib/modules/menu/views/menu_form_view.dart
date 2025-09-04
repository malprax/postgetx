import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/category_model.dart';
import '../../pos/controllers/pos_controller.dart';

class MenuFormView extends StatelessWidget {
  MenuFormView({super.key});

  final PosController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Kategori'),
              DropdownButton<CategoryModel>(
                value: controller.selectedCategory.value,
                items: controller.categories.map((category) {
                  return DropdownMenuItem<CategoryModel>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (category) {
                  controller.setCategoryFilter(category!);
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final priceText = priceController.text.trim();
                    final image = imageController.text.trim();
                    final category = controller.selectedCategory.value;

                    if (name.isEmpty || priceText.isEmpty || category == null) {
                      Get.snackbar('Gagal', 'Semua field wajib diisi');
                      return;
                    }

                    final price = int.tryParse(priceText);
                    if (price == null) {
                      Get.snackbar('Error', 'Harga tidak valid');
                      return;
                    }

                    await controller.addMenu(
                      name: name,
                      price: price,
                      category: category,
                      image: image,
                    );

                    Get.back(); // kembali ke halaman sebelumnya
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Menu'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
