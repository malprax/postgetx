import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgetx/utils/date_helper.dart';
import 'package:printing/printing.dart';

import '../../../models/order_model.dart';
import '../../../services/print_service.dart';
import '../../../utils/pdf_helper.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  Future<void> printPdf(OrderModel order) async {
    final pdf = await PdfHelper.generatePdfNota(order);
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Order Saya')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('createdBy', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada order'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final order =
                  OrderModel.fromMap(docs[i].data() as Map<String, dynamic>);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Total: Rp${order.total.toStringAsFixed(0)}"),
                  subtitle: Text(
                      "Tanggal: ${DateHelper.formatDateTime(order.createdAt)}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'print') {
                        await PrintService().printOrder(order);
                      } else if (value == 'pdf') {
                        await printPdf(order);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'print', child: Text('Cetak Ulang')),
                      const PopupMenuItem(
                          value: 'pdf', child: Text('Cetak PDF')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
