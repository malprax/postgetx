import 'package:pdf/widgets.dart' as pw;
import '../../models/order_model.dart';

class PdfHelper {
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
            pw.Text("Subtotal: Rp ${order.total.toStringAsFixed(0)}"),
            pw.Text("Diskon: ${order.discount.toStringAsFixed(0)}%"),
            pw.Text(
                "Total Bayar: Rp ${(order.total - (order.total * order.discount / 100)).toStringAsFixed(0)}"),
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
}
