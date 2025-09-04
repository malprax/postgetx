// refactored_add_menu_view.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/pos_controller.dart';
import '../../../models/category_model.dart';
import '../../../models/menu_variant.dart';

class AddMenuView extends StatefulWidget {
  const AddMenuView({super.key});

  @override
  State<AddMenuView> createState() => _AddMenuViewState();
}

class _AddMenuViewState extends State<AddMenuView> {
  final PosController controller = Get.find();
  final nameController = TextEditingController();
  CategoryModel? selectedCategory;
  File? imageFile;
  final List<MenuVariant> variants = [MenuVariant(size: '', price: 0)];

  @override
  void initState() {
    super.initState();
    selectedCategory = controller.selectedCategory.value;
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void addVariant() {
    setState(() {
      variants.add(MenuVariant(size: '', price: 0));
    });
  }

  void removeVariant(int index) {
    setState(() {
      variants.removeAt(index);
    });
  }

  Future<void> saveMenu() async {
    final name = nameController.text.trim();

    if (name.isEmpty || selectedCategory == null || variants.isEmpty) {
      Get.snackbar('Gagal', 'Data tidak lengkap');
      return;
    }

    for (var v in variants) {
      if (v.size.trim().isEmpty || v.price <= 0) {
        Get.snackbar('Gagal', 'Semua variant harus punya size dan harga > 0');
        return;
      }
    }

    try {
      await controller.firestore.collection('menus').add({
        'name': name,
        'categoryId': selectedCategory!.id,
        'categoryName': selectedCategory!.name,
        'imageUrl': imageFile?.path ?? '',
        'variants':
            variants.map((v) => {'size': v.size, 'price': v.price}).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await controller.fetchMenus();
      Get.back();
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Menu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            Obx(() => DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.categories
                      .map((e) => DropdownMenuItem<CategoryModel>(
                            value: e,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                ),
                const SizedBox(width: 12),
                if (imageFile != null)
                  Image.file(
                    imageFile!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Variants (Ukuran dan Harga)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(variants.length, (index) {
                final variant = variants[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: variant.size,
                        decoration: const InputDecoration(
                          labelText: 'Size',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            variants[index] = variant.copyWith(size: val);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: variant.price.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            variants[index] = variant.copyWith(
                                price: double.tryParse(val) ?? 0.0);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeVariant(index),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: addVariant,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Variant'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Menu'),
                onPressed: saveMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
