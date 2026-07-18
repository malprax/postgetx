// lib/modules/pos/controllers/pos_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import '../views/edit_menu_view.dart';
import 'package:postgetx/app/core/services/print_service.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';
import 'package:postgetx/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:postgetx/app/modules/orders/controllers/order_history_controller.dart';

class PosController extends GetxController {
  final logger = Logger();
  final LocalHiveRepository repository = Get.find<LocalHiveRepository>();
  final PrintService _printService = PrintService();

  RxBool isPaymentEmpty = true.obs;
  RxBool isPaymentSufficient = true.obs;
  RxBool processingCheckout = false.obs;
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
      allMenus.assignAll(await repository.getProducts());

      if (selectedCategory.value != null) {
        filterMenuByCategory(selectedCategory.value!.id);
      }
    } catch (e) {
      debugPrint('Error fetching menus: $e');
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
    if (processingCheckout.value) return;
    processingCheckout.value = true;
    try {
      currentUserEmail.value =
          Get.find<AuthController>().currentUserModel.value?.email ??
              'demo@local';
      recalculateTotal(); // pastikan paidAmount dan totalChange terupdate

      if (!isPaymentSufficient.value) {
        Get.snackbar('Error', 'Pembayaran kurang');
        return;
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final calculation = const PosTotalCalculator().calculate(
        items: cartItems,
        discountType: DiscountType.percentage,
        discountValue: discount.value,
        amountPaid: double.tryParse(payment.text.trim()) ?? 0,
      );

      final order = OrderModel(
        orderId: id,
        id: id,
        items: cartItems.toList(),
        subtotal: calculation.subtotal,
        discountType: calculation.discountType,
        discountValue: calculation.discountValue,
        discount: calculation.discountAmount,
        taxableAmount: calculation.taxableAmount,
        taxType: calculation.taxType,
        taxValue: calculation.taxValue,
        taxAmount: calculation.taxAmount,
        totalAmount: calculation.total,
        paid: calculation.amountPaid,
        change: calculation.change,
        createdBy: currentUserEmail.value,
        createdAt: DateTime.now(),
        status: OrderStatus.draft,
        receiptStatus: ReceiptState.pending,
      );

      final result = await repository.completeSale(order);
      if (!result.isSuccess) {
        Get.snackbar('Checkout failed', result.message!);
        return;
      }
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
      }
      if (Get.isRegistered<OrderHistoryController>()) {
        await Get.find<OrderHistoryController>().fetchOrders();
      }

      await _printService.printOrder(result.value!);
      await repository.updateReceiptStatus(
          result.value!.id, ReceiptState.printed);

      resetCart();
      Get.snackbar(
          'Sale complete', 'Saved locally. Dashboard totals are updated.');
    } finally {
      processingCheckout.value = false;
    }
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

    final calculation = const PosTotalCalculator().calculate(
      items: cartItems,
      discountType: DiscountType.percentage,
      discountValue: discount.value,
      amountPaid: paid,
    );
    totalAmount.value = calculation.subtotal;
    totalAfterDiscount.value = calculation.total;
    totalChange.value = calculation.change;
    isPaymentSufficient.value = paid >= calculation.total;
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty || processingCheckout.value) return;
    processingCheckout.value = true;
    try {
      final user = Get.find<AuthController>().currentUserModel.value;
      if (user == null) {
        Get.snackbar('Error', 'User belum login');
        return;
      }

      final orderId =
          "ORD-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().second}";
      final calculation = const PosTotalCalculator().calculate(
        items: cartItems,
        discountType: DiscountType.percentage,
        discountValue: discount.value,
        amountPaid: double.tryParse(payment.text.trim()) ?? 0,
      );

      final order = OrderModel(
        id: orderId,
        orderId: orderId,
        items: cartItems.toList(),
        subtotal: calculation.subtotal,
        discountType: calculation.discountType,
        discountValue: calculation.discountValue,
        discount: calculation.discountAmount,
        taxableAmount: calculation.taxableAmount,
        taxType: calculation.taxType,
        taxValue: calculation.taxValue,
        taxAmount: calculation.taxAmount,
        totalAmount: calculation.total,
        paid: calculation.amountPaid,
        change: calculation.change,
        createdAt: DateTime.now(),
        createdBy: user.uid,
        status: OrderStatus.draft,
        receiptStatus: ReceiptState.pending,
      );

      final result = await repository.completeSale(order);
      if (!result.isSuccess) {
        Get.snackbar('Checkout failed', result.message!);
        return;
      }
      Get.snackbar('Sukses', 'Order berhasil disimpan');
      resetCart();
    } finally {
      processingCheckout.value = false;
    }
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
      final fetched = await repository.getCategories();

      categories.assignAll(fetched);

      if (fetched.isNotEmpty) {
        selectedCategory.value = fetched.first;
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
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

    final newCategory = await repository.addCategory(name);

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
              initialValue: selected,
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
    allMenus.add(await repository.addProduct(
        name: name,
        categoryId: category.id,
        categoryName: category.name,
        sku: 'POS-${DateTime.now().microsecondsSinceEpoch}',
        stock: 0,
        variants: [MenuVariant(size: 'default', price: price.toDouble())]));

    Get.snackbar('Berhasil', 'Menu "$name" ditambahkan');
  }

  Future<void> editMenu(
      String menuId, String newName, List<MenuVariant> updatedVariants) async {
    try {
      final current = allMenus.firstWhere((menu) => menu.id == menuId);
      await repository.updateProduct(
          current.copyWith(name: newName, variants: updatedVariants));

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

    final updated = allMenus[index];
    final replacement = updated.copyWith(
      name: name,
      variants: [MenuVariant(size: 'default', price: price)],
    );
    await repository.updateProduct(replacement);
    allMenus[index] = replacement;

    allMenus.refresh();
    Get.snackbar('Berhasil', 'Menu diperbarui');
  }

  Future<void> deleteMenu(MenuItemModel menu) async {
    await repository.deleteProduct(menu.id);
    allMenus.removeWhere((m) => m.id == menu.id);
    Get.snackbar('Sukses', 'Menu dihapus');
  }

  Future<void> migrateMenuCategoryId() async {
    try {
      logger.i('Local data already uses category IDs.');
      Get.snackbar('Offline demo', 'No migration is required.');
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
