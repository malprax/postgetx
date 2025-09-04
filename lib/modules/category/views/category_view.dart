// lib/modules/category/views/category_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori Menu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori Baru',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      controller.addCategory(nameController.text.trim());
                      nameController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.categories.isEmpty) {
                return const Center(child: Text('Belum ada kategori.'));
              }

              return ListView.builder(
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editController.text = category.name;
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit Kategori'),
                                content: TextField(
                                  controller: editController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Kategori',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      controller.updateCategory(
                                        category.id,
                                        editController.text.trim(),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Simpan'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              controller.deleteCategory(category.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
