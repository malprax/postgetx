import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';

class PdfHelper {
  /// ✅ Untuk cetak satu struk order
  static Future<pw.Document> generatePdfNota(OrderModel order) async {
    final pdf = pw.Document();
    final receipt = ReceiptData.fromOrder(order);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text("STRUK PEMBAYARAN",
                  style: pw.TextStyle(fontSize: 18)),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Transaction: ${receipt.orderId}'),
            pw.SizedBox(height: 10),
            for (var item in receipt.items)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("${item.name} (${item.size})"),
                  pw.Text(
                      '${item.quantity} x ${RupiahFormatter.format(item.price)}'),
                  pw.SizedBox(height: 4),
                ],
              ),
            pw.SizedBox(height: 16),
            pw.Text('Subtotal: ${RupiahFormatter.format(receipt.subtotal)}'),
            pw.Text(
                'Discount${receipt.discountType == DiscountType.percentage ? ' (${receipt.discountValue.toStringAsFixed(0)}%)' : ''}: -${RupiahFormatter.format(receipt.discountAmount)}'),
            if (receipt.loyaltyPointsRedeemed > 0)
              pw.Text(
                'Loyalty (${receipt.loyaltyPointsRedeemed} pts): '
                '-${RupiahFormatter.format(receipt.loyaltyDiscount)}',
              ),
            pw.Text(
                'Taxable: ${RupiahFormatter.format(receipt.taxableAmount)}'),
            pw.Text(
                '${_taxLabel(receipt.taxType, receipt.taxValue)}: ${RupiahFormatter.format(receipt.taxAmount)}'),
            pw.Text('Total: ${RupiahFormatter.format(receipt.total)}'),
            pw.Text('Payment: ${receipt.paymentMethod.toUpperCase()}'),
            pw.Text(
                'Amount received: ${RupiahFormatter.format(receipt.amountPaid)}'),
            pw.Text(
                'Amount applied: ${RupiahFormatter.format(receipt.amountApplied)}'),
            pw.Text('Change: ${RupiahFormatter.format(receipt.change)}'),
            if (receipt.customerName?.trim().isNotEmpty == true) ...[
              pw.SizedBox(height: 10),
              pw.Text('Customer: ${receipt.customerName}'),
              pw.Text(
                'Points earned: ${receipt.loyaltyPointsEarned}',
              ),
              pw.Text(
                'Loyalty balance: ${receipt.loyaltyBalanceAfter} pts',
              ),
            ],
            pw.SizedBox(height: 16),
            pw.Center(child: pw.Text("Terima kasih!")),
          ],
        ),
      ),
    );

    return pdf;
  }

  /// 📄 Untuk ekspor banyak order ke satu file PDF (riwayat)
  static Future<pw.Document> generatePdfOrders(List<OrderModel> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Center(
              child:
                  pw.Text("RIWAYAT ORDER", style: pw.TextStyle(fontSize: 20)),
            ),
            pw.SizedBox(height: 12),
            ...orders.map((order) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Divider(),
                  pw.Text("Order ID: ${order.orderId}"),
                  pw.Text("Tanggal: ${order.createdAt}"),
                  pw.SizedBox(height: 6),
                  pw.TableHelper.fromTextArray(
                    headers: ['Menu', 'Ukuran', 'Qty', 'Harga', 'Total'],
                    data: order.items.map((item) {
                      final total = item.quantity * item.price;
                      return [
                        item.name,
                        item.size,
                        item.quantity.toString(),
                        "Rp ${item.price.toStringAsFixed(0)}",
                        "Rp ${total.toStringAsFixed(0)}"
                      ];
                    }).toList(),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                      'Subtotal: ${RupiahFormatter.format(order.subtotal)}'),
                  pw.Text(
                      'Discount: -${RupiahFormatter.format(order.discount)}'),
                  pw.Text(
                      '${_taxLabel(order.taxType, order.taxValue)}: ${RupiahFormatter.format(order.taxAmount)}'),
                  pw.Text(
                      'Total: ${RupiahFormatter.format(order.totalAmount)}'),
                  pw.Text('Payment: ${order.paymentMethod.toUpperCase()}'),
                  pw.Text(
                      'Amount received: ${RupiahFormatter.format(order.amountReceived)}'),
                  pw.Text('Change: ${RupiahFormatter.format(order.change)}'),
                  pw.SizedBox(height: 12),
                ],
              );
            })
          ];
        },
      ),
    );

    return pdf;
  }

  static String _taxLabel(TaxType type, double value) => switch (type) {
        TaxType.percentage => 'Tax (${value.toStringAsFixed(0)}%)',
        TaxType.fixedAmount => 'Tax',
        TaxType.none => 'Tax (None)',
      };
}
