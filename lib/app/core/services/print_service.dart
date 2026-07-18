import 'package:printing/printing.dart';

import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/core/services/pdf_helper.dart';
import 'package:postgetx/app/core/services/printer_service.dart';

/// Offline-safe printer implementation.
///
/// A future Bluetooth adapter can implement [PrinterService] without changing
/// controllers. Until then Android and Web both use the system PDF preview.
class PrintService implements PrinterService {
  @override
  Future<void> printOrder(OrderModel order) async {
    final pdf = await PdfHelper.generatePdfNota(order);
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}
