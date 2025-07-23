import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/menu_item_model.dart';
import '../../../services/print_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PosController extends GetxController {
  final menuItems = <MenuItemModel>[].obs;
  final cartItems = <CartItemModel>[].obs;
  final discount = 0.0.obs;
  final payment = TextEditingController();

  final totalAmount = 0.0.obs;
  final totalAfterDiscount = 0.0.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    fetchMenuItems();
    super.onInit();
  }

  void fetchMenuItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('menu').get();

    final items = snapshot.docs
        .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
        .toList();
    menuItems.assignAll(items);
  }

  void addItem(MenuItemModel item, String size) {
    final existing =
        cartItems.indexWhere((e) => e.id == item.id && e.size == size);
    if (existing != -1) {
      cartItems[existing].quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(
        id: item.id,
        name: item.name,
        price: (item.prices[size] ?? 0).toDouble(),
        quantity: 1,
        size: size,
      ));
    }
    calculateTotal();
  }

  void removeItem(CartItemModel item) {
    cartItems.remove(item);
    calculateTotal();
  }

  void increaseQty(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
    calculateTotal();
  }

  void decreaseQty(CartItemModel item) {
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

  Future<void> checkout() async {
    final paymentReceived = double.tryParse(payment.text) ?? 0;
    final change = paymentReceived - totalAfterDiscount.value;

    if (paymentReceived < totalAfterDiscount.value) {
      Get.snackbar('Pembayaran Kurang', 'Jumlah pembayaran tidak mencukupi.');
      return;
    }

    try {
      isLoading.value = true;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final now = DateTime.now();

      // Simpan ke Firestore (orders)
      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add({
        'items': cartItems.map((e) => e.toMap()).toList(),
        'total': totalAfterDiscount.value,
        'discount': discount.value,
        'payment': paymentReceived,
        'change': change,
        'createdBy': uid,
        'createdAt': now,
      });

      // Simpan ke order_logs
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

      // Simpan ke sales_report
      await FirebaseFirestore.instance.collection('sales_report').add({
        'date': now.toIso8601String().substring(0, 10),
        'total': totalAfterDiscount.value,
        'userId': uid,
        'createdAt': now,
      });

      // Cetak nota ke printer
      await PrintService().printReceipt(
        items: cartItems,
        total: totalAmount.value,
        discount: discount.value,
        paid: paymentReceived,
        change: change,
      );

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
          Get.back(); // Tutup dialog
        },
      );

      // Reset keranjang
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
}
