import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/menu_item_model.dart';
import '../controllers/menu_controller.dart' as menu;
import '../controllers/category_controller.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(menu.MenuController());
    final categoryController = Get.put(CategoryController());

    final nameController = TextEditingController();
    final priceSmallController = TextEditingController();
    final priceLargeController = TextEditingController();

    RxString selectedCategoryId = ''.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => DropdownButton<String>(
                  value: selectedCategoryId.value.isEmpty &&
                          categoryController.categories.isNotEmpty
                      ? categoryController.categories.first.id
                      : selectedCategoryId.value,
                  onChanged: (value) => selectedCategoryId.value = value ?? '',
                  items: categoryController.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                      .toList(),
                )),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Menu Name')),
            TextField(
                controller: priceSmallController,
                decoration: const InputDecoration(labelText: 'Price Small'),
                keyboardType: TextInputType.number),
            TextField(
                controller: priceLargeController,
                decoration: const InputDecoration(labelText: 'Price Large'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final menu = MenuItemModel(
                  id: '',
                  categoryId: selectedCategoryId.value,
                  name: nameController.text,
                  prices: {
                    'Small': double.tryParse(priceSmallController.text) ?? 0,
                    'Large': double.tryParse(priceLargeController.text) ?? 0,
                  },
                );
                menuController.addMenuItem(menu);
                nameController.clear();
                priceSmallController.clear();
                priceLargeController.clear();
              },
              child: const Text('Add Menu Item'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: menuController.menuItems.length,
                    itemBuilder: (_, index) {
                      final item = menuController.menuItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                            "Small: ${item.prices['Small'] ?? '-'} | Large: ${item.prices['Large'] ?? '-'}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              menuController.deleteMenuItem(item.id),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
