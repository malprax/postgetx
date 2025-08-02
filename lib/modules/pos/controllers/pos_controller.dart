import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postgetx/modules/auth/controllers/auth_controller.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../services/print_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PosController extends GetxController {
  final auth = Get.find<AuthController>();
  final menuItems = <MenuItemModel>[].obs;
  final cartItems = <CartItemModel>[].obs;
  final discount = 0.0.obs;
  final payment = TextEditingController();
  final totalAmount = 0.0.obs;
  final totalAfterDiscount = 0.0.obs;
  final isLoading = false.obs;

  final categories = <String>["All"].obs;
  final selectedCategory = "All".obs;

  List<MenuItemModel> get filteredMenu {
    if (selectedCategory.value == 'All') return menuItems;
    return menuItems
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  @override
  void onInit() {
    fetchMenuItems();
    super.onInit();
  }

  void fetchMenuItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('menu_items').get();
      menuItems.value = snapshot.docs
          .map((doc) => MenuItemModel.fromMap(
              doc.data() as String, doc.id as Map<String, dynamic>))
          .toList();

      // Extract categories from menu items
      final allCategories = menuItems.map((e) => e.category).toSet().toList();
      allCategories.sort();
      categories.value = ['All', ...allCategories];
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data menu: $e');
    }
  }

  void setCategoryFilter(String category) {
    selectedCategory.value = category;
  }

  void addItem(MenuItemModel item, String size) {
    final existing =
        cartItems.indexWhere((e) => e.id == item.id && e.size == size);
    if (existing != -1) {
      cartItems[existing].quantity++;
      cartItems.refresh();
    } else {
      final variant = item.variants.firstWhere((v) => v.size == size);
      cartItems.add(CartItemModel(
        id: item.id,
        name: item.name,
        price: variant.price.toDouble(),
        quantity: 1,
        size: size,
        isExtra: item.isExtra,
      ));
    }
    calculateTotal();
  }

  void removeItem(CartItemModel item) {
    cartItems.remove(item);
    calculateTotal();
  }

  void increaseQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
    calculateTotal();
  }

  void decreaseQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      cartItems.remove(item);
    }
    calculateTotal();
  }

  void calculateTotal() {
    totalAmount.value =
        cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    totalAfterDiscount.value = totalAmount.value * (1 - discount.value / 100);
  }

  void setDiscount(double value) {
    discount.value = value;
    calculateTotal();
  }

  Future<void> printReceipt() async {
    final paid = double.tryParse(payment.text) ?? 0;
    final change = paid - totalAfterDiscount.value;

    await PrintService().printReceipt(
      items: cartItems,
      total: totalAmount.value,
      discount: discount.value,
      paid: paid,
      change: change,
    );
  }

  Future<void> checkout() async {
    final paymentReceived = double.tryParse(payment.text) ?? 0;
    final change = paymentReceived - totalAfterDiscount.value;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Belum Login", "Silakan login terlebih dahulu.");
      return;
    }

    if (!user.emailVerified) {
      Get.snackbar("Email Belum Diverifikasi",
          "Silakan verifikasi email Anda terlebih dahulu.");
      return;
    }

    if (paymentReceived < totalAfterDiscount.value) {
      Get.snackbar('Pembayaran Kurang', 'Jumlah pembayaran tidak mencukupi.');
      return;
    }

    try {
      isLoading.value = true;
      final uid = user.uid;
      final now = DateTime.now();

      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add({
        'items': cartItems.map((e) => e.toMap()).toList(),
        'total': totalAmount.value,
        'discount': discount.value,
        'paid': paymentReceived,
        'change': change,
        'createdBy': uid,
        'createdAt': now,
      });

      for (var item in cartItems) {
        await FirebaseFirestore.instance.collection('order_logs').add({
          'orderId': orderRef.id,
          'itemId': item.id,
          'itemName': item.name,
          'qty': item.quantity,
          'price': item.price,
          'total': item.quantity * item.price,
          'createdAt': now,
          'createdBy': uid,
        });
      }

      await FirebaseFirestore.instance.collection('sales_report').add({
        'date': now.toIso8601String().substring(0, 10),
        'total': totalAfterDiscount.value,
        'userId': uid,
        'createdAt': now,
      });

      await printReceipt();

      Get.defaultDialog(
        title: 'Pembayaran Sukses',
        content: Column(
          children: [
            Text(
                'Total Bayar: Rp ${totalAfterDiscount.value.toStringAsFixed(0)}'),
            Text('Tunai: Rp ${paymentReceived.toStringAsFixed(0)}'),
            Text('Kembalian: Rp ${change.toStringAsFixed(0)}'),
          ],
        ),
        textConfirm: 'OK',
        onConfirm: () {
          Get.back();
        },
      );

      cartItems.clear();
      payment.clear();
      discount.value = 0;
      calculateTotal();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan transaksi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveOrderToFirestore({
    required double amountPaid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    final now = DateTime.now();

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'cashierId': user.uid,
      'cashierName': auth.currentUserModel.value?.name ?? '',
      'total': totalAmount.value,
      'discount': discount.value,
      'totalAfterDiscount': totalAfterDiscount.value,
      'amountPaid': amountPaid,
      'change': amountPaid - totalAfterDiscount.value,
      'createdAt': now.toIso8601String(),
    });

    for (final item in cartItems) {
      await FirebaseFirestore.instance.collection('order_items').add({
        'orderId': orderId,
        'name': item.name,
        'size': item.size,
        'price': item.price,
        'quantity': item.quantity,
        'subtotal': item.price * item.quantity,
      });
    }
  }
}
