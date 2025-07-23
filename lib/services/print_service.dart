import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:postgetx/models/cart_item_model.dart';
import '../../../models/order_model.dart';

class PrintService {
  final printer = BlueThermalPrinter.instance;

  Future<void> printReceipt({
    required List<CartItemModel> items,
    required double total,
    required double discount,
    required double paid,
    required double change,
  }) async {
    try {
      final isConnected = await printer.isConnected ?? false;
      if (!isConnected) return;

      printer.printNewLine();
      printer.printCustom("STRUK PEMBAYARAN", 2, 1);
      printer.printNewLine();
      for (var item in items) {
        printer.printCustom("${item.name} (${item.size})", 1, 0);
        printer.printCustom(
            "${item.quantity} x ${item.price} = Rp ${(item.quantity * item.price).toStringAsFixed(0)}",
            0,
            0);
      }
      printer.printNewLine();
      printer.printCustom("Subtotal : Rp ${total.toStringAsFixed(0)}", 1, 0);
      printer.printCustom("Diskon : ${discount.toStringAsFixed(0)}%", 1, 0);
      printer.printCustom(
          "Total Bayar : Rp ${(total - (total * discount / 100)).toStringAsFixed(0)}",
          1,
          0);
      printer.printCustom("Tunai : Rp ${paid.toStringAsFixed(0)}", 1, 0);
      printer.printCustom("Kembalian : Rp ${change.toStringAsFixed(0)}", 1, 0);
      printer.printNewLine();
      printer.printCustom("Terima kasih!", 1, 1);
      printer.printNewLine();
      printer.paperCut();
    } catch (e) {
      print("Printer error: $e");
    }
  }

  Future<void> printOrder(OrderModel order) async {
    await printReceipt(
      items: order.items,
      total: order.total,
      discount: order.discount,
      paid: order.paid,
      change: order.change,
    );
  }
}
