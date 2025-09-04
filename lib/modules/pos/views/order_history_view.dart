import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/order_model.dart';
import '../../../models/cart_item_model.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Order")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Terjadi kesalahan");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada order"));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final order = OrderModel.fromMap(docs[index].id, data);

              return ExpansionTile(
                title: Text("🧾 ${order.orderId}"),
                subtitle:
                    Text("Total: Rp ${order.totalAmount.toStringAsFixed(0)}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in order.items)
                          ListTile(
                            title: Text(item.name),
                            subtitle: Text("Ukuran: ${item.size}"),
                            trailing: Text("x${item.quantity}"),
                          ),
                        const SizedBox(height: 8),
                        Text("Dibuat oleh: ${order.createdBy}"),
                        Text("Dibuat pada: ${order.createdAt.toDate()}"),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
