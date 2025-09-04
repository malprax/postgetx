import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/order_model.dart';

class PdfHelper {
  /// ✅ Untuk cetak satu struk order
  static Future<pw.Document> generatePdfNota(OrderModel order) async {
    final pdf = pw.Document();

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
            for (var item in order.items)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("${item.name} (${item.size})"),
                  pw.Text(
                      "${item.quantity} x ${item.price} = Rp ${(item.quantity * item.price).toStringAsFixed(0)}"),
                  pw.SizedBox(height: 4),
                ],
              ),
            pw.SizedBox(height: 16),
            pw.Text("Subtotal: Rp ${order.totalAmount.toStringAsFixed(0)}"),
            pw.Text("Diskon: ${order.discount.toStringAsFixed(0)}%"),
            pw.Text(
                "Total Bayar: Rp ${(order.totalAmount - (order.totalAmount * order.discount / 100)).toStringAsFixed(0)}"),
            pw.Text("Tunai: Rp ${order.paid.toStringAsFixed(0)}"),
            pw.Text("Kembalian: Rp ${order.change.toStringAsFixed(0)}"),
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
                  pw.Text("Tanggal: ${order.createdAt.toDate()}"),
                  pw.SizedBox(height: 6),
                  pw.Table.fromTextArray(
                    headers: ['Menu', 'Ukuran', 'Qty', 'Harga', 'Total'],
                    data: order.items.map((item) {
                      final total = item.quantity * item.price;
                      return [
                        item.name,
                        item.size ?? '-',
                        item.quantity.toString(),
                        "Rp ${item.price.toStringAsFixed(0)}",
                        "Rp ${total.toStringAsFixed(0)}"
                      ];
                    }).toList(),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                      "Subtotal: Rp ${order.totalAmount.toStringAsFixed(0)}"),
                  pw.Text("Diskon: ${order.discount.toStringAsFixed(0)}%"),
                  pw.Text(
                      "Total Bayar: Rp ${(order.totalAmount - (order.totalAmount * order.discount / 100)).toStringAsFixed(0)}"),
                  pw.Text("Tunai: Rp ${order.paid.toStringAsFixed(0)}"),
                  pw.Text("Kembalian: Rp ${order.change.toStringAsFixed(0)}"),
                  pw.SizedBox(height: 12),
                ],
              );
            }).toList()
          ];
        },
      ),
    );

    return pdf;
  }
}
