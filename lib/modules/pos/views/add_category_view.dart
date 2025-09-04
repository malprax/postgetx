// lib/modules/pos/views/add_category_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pos_controller.dart';
import '../../../models/category_model.dart';

class AddCategoryView extends StatelessWidget {
  AddCategoryView({super.key});

  final PosController controller = Get.find();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  Get.snackbar('Gagal', 'Nama kategori tidak boleh kosong');
                  return;
                }

                // Check for duplicates
                if (controller.categories
                    .any((c) => c.name.toLowerCase() == name.toLowerCase())) {
                  Get.snackbar('Duplikat', 'Kategori "$name" sudah ada');
                  return;
                }

                await controller.addCategory(name);
                controller.fetchCategories();
                Get.back();
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }
}
