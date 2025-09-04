// lib/modules/menu/views/menu_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/menu_variant.dart';
import '../controllers/menu_controller.dart' as my_menu;
import '../../category/controllers/category_controller.dart';
import '../../../models/menu_item_model.dart';

class MenuView extends StatelessWidget {
  final my_menu.MenuController menuController =
      Get.put(my_menu.MenuController());
  final CategoryController categoryController = Get.put(CategoryController());

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryIdController = TextEditingController();
  final categoryNameController = TextEditingController();
  final sizeController = TextEditingController();
  final priceController = TextEditingController();
  final RxList<MenuVariant> variants = <MenuVariant>[].obs;

  void _showAddMenuDialog(BuildContext context) {
    nameController.clear();
    descriptionController.clear();
    categoryIdController.clear();
    categoryNameController.clear();
    variants.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Menu"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Menu'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              Obx(() {
                final cats = categoryController.categories;
                return DropdownButtonFormField<String>(
                  value: cats.isNotEmpty ? cats.first.id : null,
                  items: cats
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    final cat = cats.firstWhereOrNull((e) => e.id == value);
                    if (cat != null) {
                      categoryIdController.text = cat.id;
                      categoryNameController.text = cat.name;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                );
              }),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(labelText: 'Ukuran'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (sizeController.text.isNotEmpty &&
                          priceController.text.isNotEmpty) {
                        variants.add(MenuVariant(
                          size: sizeController.text,
                          price: double.tryParse(priceController.text) ?? 0,
                        ));
                        sizeController.clear();
                        priceController.clear();
                      }
                    },
                  )
                ],
              ),
              Obx(() => Column(
                    children: variants
                        .map((v) => ListTile(
                              title: Text(v.size),
                              subtitle: Text("Rp ${v.price}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => variants.remove(v),
                              ),
                            ))
                        .toList(),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final catId = categoryIdController.text.trim();
              final catName = categoryNameController.text.trim();

              if (name.isEmpty ||
                  catId.isEmpty ||
                  catName.isEmpty ||
                  variants.isEmpty) {
                Get.snackbar('Gagal', 'Nama, kategori, dan varian harus diisi');
                return;
              }

              final isDuplicate = menuController.isDuplicate(name, catName);
              if (isDuplicate) {
                Get.snackbar('Gagal',
                    'Menu dengan nama yang sama sudah ada di kategori ini');
                return;
              }

              final menu = MenuItemModel(
                id: '',
                name: name,
                description: descriptionController.text.trim(),
                categoryId: catId,
                categoryName: catName,
                imageUrl: '',
                variants: variants.toList(),
              );

              await menuController.saveMenu(menu);
              Navigator.of(context).pop();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Menu'),
      ),
      body: Obx(() {
        final categories = categoryController.categories;
        final items = menuController.menuItems;

        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Belum ada kategori'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/category'),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Kategori'),
                ),
              ],
            ),
          );
        }

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Belum ada menu'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _showAddMenuDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Menu'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            return ListTile(
              leading: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(item.imageUrl!,
                      width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(item.name),
              subtitle: Text(item.categoryName!),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => menuController.deleteMenuItem(item.id),
              ),
              onTap: () => Get.toNamed('/menu_form', arguments: item),
            );
          },
        );
      }),
      floatingActionButton: Obx(() {
        if (categoryController.categories.isEmpty) return const SizedBox();
        return FloatingActionButton(
          onPressed: () => _showAddMenuDialog(context),
          child: const Icon(Icons.add),
        );
      }),
    );
  }
}
