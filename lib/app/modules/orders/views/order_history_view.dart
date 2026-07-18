import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:postgetx/routes/app_routes.dart';
import 'package:postgetx/app/core/services/print_service.dart';
import 'package:postgetx/utils/pdf_helper.dart';
import 'package:postgetx/widgets/demo_mode_banner.dart';
import 'package:postgetx/app/modules/orders/controllers/order_history_controller.dart';

class OrderHistoryView extends StatelessWidget {
  OrderHistoryView({super.key});
  final controller = Get.put(OrderHistoryController());
  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            tooltip: 'Export PDF report',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdf = await PdfHelper.generatePdfOrders(controller.orders);
              await Printing.layoutPdf(onLayout: (_) => pdf.save());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const DemoModeBanner(),
          Expanded(
            child: Obx(() {
              if (controller.orders.isEmpty) {
                return const Center(child: Text('No local transactions yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final order = controller.orders[index];
                  final total = order.totalAmount * (1 - order.discount / 100);
                  return Card(
                    child: ListTile(
                      title: Text(order.orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${DateFormat.yMMMd().add_jm().format(order.createdAt)} • ${order.items.length} line items'),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(currency.format(total),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                              tooltip: 'Preview receipt',
                              icon: const Icon(Icons.receipt_long),
                              onPressed: () =>
                                  PrintService().printOrder(order)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.offAllNamed(Routes.dashboard),
        icon: const Icon(Icons.dashboard_outlined),
        label: const Text('Dashboard'),
      ),
    );
  }
}
