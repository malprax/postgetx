// lib/modules/pos/controllers/pos_controller.dart
import 'dart:ffi';

import 'package:get/get.dart';

class PosController extends GetxController {
  RxInt itemCount = 0.obs;
  RxInt totalPrice = 0.obs;

  void addItem(RxInt qty, RxInt price) {
    itemCount.value += qty.value;
    totalPrice.value += (qty.value * price.value);
  }

  void reset() {
    itemCount.value = 0;
    totalPrice.value = 0;
  }
}
