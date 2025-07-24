import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add Category Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      controller.addCategory(nameController.text.trim());
                      nameController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category List
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.categories.length,
                    itemBuilder: (_, i) {
                      final category = controller.categories[i];
                      final editController =
                          TextEditingController(text: category.name);

                      return ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Edit Category',
                                  content: TextField(
                                    controller: editController,
                                    decoration: const InputDecoration(
                                        labelText: 'New Name'),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.updateCategory(category.id,
                                            editController.text.trim());
                                        Get.back();
                                      },
                                      child: const Text('Save'),
                                    )
                                  ],
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
                  )),
            )
          ],
        ),
      ),
    );
  }
}
