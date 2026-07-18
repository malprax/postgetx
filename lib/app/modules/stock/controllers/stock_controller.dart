// lib/modules/stock/controllers/stock_controller.dart
import 'package:get/get.dart';

class StockController extends GetxController {
  var stockList = <Map<String, dynamic>>[].obs;

  void addStock(String name, int quantity) {
    stockList.add({'name': name, 'qty': quantity});
  }

  void clearStock() {
    stockList.clear();
  }
}
