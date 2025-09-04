// lib/modules/pos/controllers/pos_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/web.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/menu_variant.dart';
import '../../../models/order_model.dart';
import '../../../models/category_model.dart';
import '../views/edit_menu_view.dart';
import '../../../services/print_service.dart';

class PosController extends GetxController {
  final logger = Logger();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final PrintService _printService = PrintService();

  RxBool isPaymentEmpty = true.obs;
  RxBool isPaymentSufficient = true.obs;
  RxList<MenuItemModel> allMenus = <MenuItemModel>[].obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  RxDouble totalAmount = 0.0.obs;
  RxDouble totalChange = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxDouble totalAfterDiscount = 0.0.obs;
  RxString currentUserEmail = ''.obs;

  final payment = TextEditingController();

  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchMenus();
  }

  void resetFormFields() {
    nameController.clear();
    priceController.clear();
  }

  Future<void> fetchMenus() async {
    try {
      final snapshot = await firestore.collection('menus').get();
      allMenus.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        return MenuItemModel.fromMap(doc.id, data);
      }).toList());

      if (selectedCategory.value != null) {
        filterMenuByCategory(selectedCategory.value!.id);
      }
    } catch (e) {
      print('❌ Error fetching menus: $e');
    }
  }

  List<MenuItemModel> get filteredMenu {
    return selectedCategory.value == null
        ? allMenus
        : allMenus
            .where((menu) => menu.categoryId == selectedCategory.value!.id)
            .toList();
  }

  void setCategoryFilter(CategoryModel category) {
    selectedCategory.value = category;
  }

  Future<void> checkoutAndPrint() async {
    currentUserEmail.value = FirebaseAuth.instance.currentUser?.email ?? '';
    recalculateTotal(); // pastikan paidAmount dan totalChange terupdate

    if (!isPaymentSufficient.value) {
      Get.snackbar('Error', 'Pembayaran kurang');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final order = OrderModel(
      orderId: id,
      id: id,
      items: cartItems.toList(),
      totalAmount: totalAmount.value, // total sebelum diskon
      discount: discount.value,
      paid: double.tryParse(payment.text.trim()) ?? 0.0,
      change: totalChange.value,
      createdBy: currentUserEmail.value,
      createdAt: Timestamp.now(),
    );

    await firestore.collection('orders').doc(order.id).set(order.toMap());

    await _printService.printOrder(order); // ✅ panggil printer

    resetCart();
    Get.snackbar('Sukses', 'Pembayaran dan cetak nota berhasil');
  }

  void addItem(MenuItemModel item, String size) {
    final variant = item.variants.firstWhere((v) => v.size == size);
    final existing = cartItems.indexWhere(
      (e) => e.name == item.name && e.size == size,
    );

    if (existing != -1) {
      cartItems[existing].quantity += 1;
    } else {
      cartItems.add(CartItemModel(
        id: item.id,
        name: item.name,
        size: size,
        price: variant.price,
        quantity: 1,
      ));
    }

    recalculateTotal();
  }

  void increaseQuantity(CartItemModel item) {
    item.quantity += 1;
    cartItems.refresh();
    recalculateTotal();
  }

  void decreaseQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      cartItems.remove(item);
    }
    cartItems.refresh();
    recalculateTotal();
  }

  void removeItem(CartItemModel item) {
    cartItems.remove(item);
    recalculateTotal();
  }

  void setDiscount(double value) {
    discount.value = value;
    recalculateTotal();
  }

  void recalculateTotal() {
    final paidText = payment.text.trim();
    isPaymentEmpty.value = paidText.isEmpty;

    final paid = double.tryParse(paidText) ?? 0.0;

    totalAmount.value =
        cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    totalAfterDiscount.value =
        totalAmount.value * ((100 - discount.value) / 100);

    final change = paid - totalAfterDiscount.value;
    totalChange.value = change < 0 ? 0.0 : change;

    isPaymentSufficient.value = paid >= totalAfterDiscount.value;
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User belum login');
      return;
    }

    final orderId =
        "ORD-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().second}";

    final order = OrderModel(
      id: '',
      orderId: orderId,
      items: cartItems.toList(),
      totalAmount: totalAmount.value,
      discount: discount.value,
      paid: double.tryParse(payment.text) ?? 0.0,
      change: totalChange.value,
      createdAt: Timestamp.now(),
      createdBy: user.uid,
    );

    await firestore.collection('orders').add(order.toMap());
    Get.snackbar('Sukses', 'Order berhasil disimpan');
    resetCart();
  }

  void resetCart() {
    cartItems.clear();
    totalAmount.value = 0;
    totalAfterDiscount.value = 0;
    discount.value = 0;
    payment.clear();
    totalChange.value = 0;
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await firestore.collection('categories').get();
      final fetched = snapshot.docs.map((doc) {
        final data = doc.data();
        return CategoryModel.fromMap(doc.id, data);
      }).toList();

      categories.assignAll(fetched);

      if (fetched.isNotEmpty) {
        selectedCategory.value = fetched.first;
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
    }
  }

  void showAddCategoryDialog() {
    final nameController = TextEditingController();

    Get.defaultDialog(
      title: "Tambah Kategori",
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nama Kategori"),
          ),
        ],
      ),
      textCancel: "Batal",
      textConfirm: "Simpan",
      onConfirm: () async {
        final name = nameController.text.trim();
        if (name.isEmpty) {
          Get.snackbar("Gagal", "Nama kategori tidak boleh kosong");
          return;
        }

        await addCategory(name); // pastikan kamu punya method ini
        Get.back();
      },
    );
  }

  Future<void> addCategory(String name) async {
    if (name.isEmpty) {
      Get.snackbar('Gagal', 'Nama kategori tidak boleh kosong');
      return;
    }

    final isDuplicate =
        categories.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (isDuplicate) {
      Get.snackbar('Duplikat', 'Kategori "$name" sudah ada');
      return;
    }

    final doc = await firestore.collection('categories').add({'name': name});
    final newCategory = CategoryModel(id: doc.id, name: name);

    categories.add(newCategory);
    selectedCategory.value = newCategory;

    Get.snackbar('Berhasil', 'Kategori "$name" ditambahkan');
  }

  void filterMenuByCategory(String categoryId) {
    selectedCategory.value =
        categories.firstWhereOrNull((cat) => cat.id == categoryId);
  }

  void showAddMenuDialog() {
    nameController.clear();
    priceController.clear();

    CategoryModel? selected = selectedCategory.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CategoryModel>(
              value: selected,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name),
                      ))
                  .toList(),
              onChanged: (val) => selected = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = int.tryParse(priceController.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0 || selected == null) {
                Get.snackbar('Gagal', 'Lengkapi semua isian dengan benar');
                return;
              }

              await addMenu(
                name: name,
                price: price,
                category: selected!,
                image: '',
              );

              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> addMenu({
    required String name,
    required int price,
    required CategoryModel category,
    required String image,
  }) async {
    final newMenu = {
      'name': name,
      'categoryId': category.id,
      'categoryName': category.name,
      'imageUrl': image,
      'variants': [
        {'size': 'default', 'price': price.toDouble()}
      ],
      'createdAt': FieldValue.serverTimestamp(),
    };

    final doc = await firestore.collection('menus').add(newMenu);

    allMenus.add(MenuItemModel(
      id: doc.id,
      name: name,
      categoryId: category.id,
      categoryName: category.name,
      imageUrl: image,
      variants: [MenuVariant(size: 'default', price: price.toDouble())],
    ));

    Get.snackbar('Berhasil', 'Menu "$name" ditambahkan');
  }

  Future<void> editMenu(
      String menuId, String newName, List<MenuVariant> updatedVariants) async {
    try {
      await firestore.collection('menus').doc(menuId).update({
        'name': newName,
        'variants': updatedVariants
            .map((v) => {'size': v.size, 'price': v.price})
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchMenus(); // Refresh menu list
      Get.snackbar('Sukses', 'Menu berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengupdate menu: $e');
    }
  }

  void showEditMenuDialog(MenuItemModel menu) {
    nameController.text = menu.name;
    priceController.text = menu.variants.first.price.toInt().toString();

    Get.dialog(EditMenuView(menu: menu));
  }

  Future<void> updateMenu(String menuId, String name, double price) async {
    final index = allMenus.indexWhere((m) => m.id == menuId);
    if (index == -1) return;

    await firestore.collection('menus').doc(menuId).update({
      'name': name,
      'variants': [
        {'size': 'default', 'price': price},
      ],
    });

    final updated = allMenus[index];
    allMenus[index] = updated.copyWith(
      name: name,
      variants: [MenuVariant(size: 'default', price: price)],
    );

    allMenus.refresh();
    Get.snackbar('Berhasil', 'Menu diperbarui');
  }

  Future<void> deleteMenu(MenuItemModel menu) async {
    await firestore.collection('menus').doc(menu.id).delete();
    allMenus.removeWhere((m) => m.id == menu.id);
    Get.snackbar('Sukses', 'Menu dihapus');
  }

  Future<void> migrateMenuCategoryId() async {
    try {
      logger.i("🔄 Memulai proses migrasi categoryId...");

      final menuSnapshot = await firestore.collection('menus').get();
      logger.i("📦 Total menu ditemukan: ${menuSnapshot.docs.length}");

      final categorySnapshot = await firestore.collection('categories').get();
      logger.i("📁 Total kategori ditemukan: ${categorySnapshot.docs.length}");

      final categoryMap = {
        for (var doc in categorySnapshot.docs) doc['name']: doc.id,
      };
      logger.d("🗺️ categoryMap: $categoryMap");

      int updatedCount = 0;

      for (var doc in menuSnapshot.docs) {
        final data = doc.data();
        final menuId = doc.id;
        final menuName = data['name'] ?? 'Unknown';

        logger.d("🔍 Memeriksa menu: $menuId ($menuName)");

        if (!data.containsKey('categoryId') &&
            data.containsKey('categoryName')) {
          final categoryName = data['categoryName'];
          final categoryId = categoryMap[categoryName];

          logger.d(
              "➡️ Menu '$menuName' pakai categoryName: $categoryName → categoryId: $categoryId");

          if (categoryId != null) {
            await firestore.collection('menus').doc(menuId).update({
              'categoryId': categoryId,
            });
            updatedCount++;
            logger.i(
                "✅ Berhasil update menu '$menuName' ($menuId) → categoryId: $categoryId");
          } else {
            logger.w(
                "⚠️ Tidak ditemukan categoryId untuk categoryName: $categoryName");
          }
        } else {
          logger.d(
              "⏭️ Lewatkan menu $menuId, sudah punya categoryId atau tidak punya categoryName.");
        }
      }

      logger.i("🎉 Migrasi selesai. Total menu diperbarui: $updatedCount");

      Get.snackbar(
        'Migrasi Selesai',
        '$updatedCount menu diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stacktrace) {
      logger.e(
        "❌ Terjadi error saat migrasi",
        error: e,
        stackTrace: stacktrace,
      );

      Get.snackbar(
        'Error Migrasi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
