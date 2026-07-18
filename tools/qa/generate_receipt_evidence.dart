import 'dart:io';

import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/models/order_lifecycle.dart';
import 'package:postgetx/models/order_model.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/utils/pdf_helper.dart';

Future<void> main() async {
  final paidAt = DateTime(2026, 7, 17, 9, 20);
  final order = OrderModel(
    id: 'qa-t-1246485',
    orderId: 'T-1246485',
    items: [
      CartItemModel(
        id: 'WTR500',
        name: 'Water Bottle 500ml',
        size: '500ml',
        price: 7500,
        quantity: 1,
      ),
    ],
    subtotal: 7500,
    discount: 750,
    discountType: DiscountType.percentage,
    discountValue: 10,
    taxableAmount: 6750,
    taxType: TaxType.percentage,
    taxValue: 10,
    taxAmount: 675,
    totalAmount: 7425,
    paid: 10000,
    amountReceived: 10000,
    amountApplied: 7425,
    change: 2575,
    createdAt: paidAt,
    completedAt: paidAt,
    paidAt: paidAt,
    createdBy: 'demo-owner',
    createdByName: 'Demo Owner',
    updatedBy: 'demo-owner',
    status: OrderStatus.completed,
    receiptStatus: ReceiptState.printed,
    paymentMethod: 'cash',
  );

  final receipt = await PdfHelper.generatePdfNota(order);
  final output = File('artifacts/qa/04_receipt_with_change.pdf');
  await output.parent.create(recursive: true);
  await output.writeAsBytes(await receipt.save());
  stdout.writeln(output.absolute.path);
}
