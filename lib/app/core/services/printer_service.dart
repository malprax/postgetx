import 'package:postgetx/app/data/models/order_model.dart';

abstract class PrinterService {
  Future<void> printOrder(OrderModel order);
}
