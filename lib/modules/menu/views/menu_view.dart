// menu_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/menu/controllers/menu_controller.dart'
    as menu_controller;

class MenuView extends StatelessWidget {
  final menuController = Get.put(menu_controller.MenuController());

  @override
  Widget build(BuildContext context) {
    menuController.fetchMenus();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: menuController.nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: menuController.categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: menuController.basePriceController,
                  decoration: const InputDecoration(labelText: 'Base Price'),
                  keyboardType: TextInputType.number,
                ),
                Obx(() => Wrap(
                      children: menuController.extras
                          .map((extra) => Chip(label: Text(extra)))
                          .toList(),
                    )),
                ElevatedButton(
                  onPressed: menuController.addMenu,
                  child: const Text('Add Menu'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: menuController.menus.length,
                itemBuilder: (context, index) {
                  final menu = menuController.menus[index];
                  return ListTile(
                    title: Text(menu.name),
                    subtitle: Text(
                        "${menu.category} | Extras: ${menu.extras.join(', ')}"),
                    trailing: Text("Rp${menu.basePrice.toStringAsFixed(0)}"),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
