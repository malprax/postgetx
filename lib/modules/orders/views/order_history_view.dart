// lib/modules/orders/views/order_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';
import '../../../models/order_model.dart';
import '../../../services/print_service.dart';
import '../../../utils/date_helper.dart';
import '../../../utils/pdf_helper.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final orders = <OrderModel>[];
  final searchController = TextEditingController();
  DateTimeRange? dateRange;
  int pageSize = 10;
  final List<int> pageSizeOptions = [10, 25, 50, 0];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  String pageSizeLabel(int value) => value == 0 ? 'Semua' : '$value';

  Future<void> fetchOrders() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      orders.clear();
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (dateRange != null) {
      query = query
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange!.start))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(dateRange!.end));
    }

    if (pageSize > 0) {
      query = query.limit(pageSize);
    }

    final snapshot = await query.get();
    setState(() {
      orders.addAll(snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList());
      isLoading = false;
    });
  }

  void searchOrderById(String id) async {
    setState(() {
      isLoading = true;
      orders.clear();
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderId', isEqualTo: id)
        .get();

    setState(() {
      orders.addAll(snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList());
      isLoading = false;
    });
  }

  Future<void> exportAllOrdersToPdf() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    final allOrders = snapshot.docs
        .map((doc) =>
            OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    final pdf = await PdfHelper.generatePdfOrders(allOrders);
    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => dateRange = picked);
      fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Order Saya')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan Order ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          fetchOrders();
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        searchOrderById(value);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: pickDateRange,
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: "Ekspor semua order ke PDF",
                  onPressed: exportAllOrdersToPdf,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Row(
              children: [
                const Text("Tampilkan: "),
                DropdownButton<int>(
                  value: pageSize,
                  items: pageSizeOptions.map((val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Text("${pageSizeLabel(val)} data"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => pageSize = value);
                      fetchOrders();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text("Belum ada order"))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (_, i) {
                          final order = orders[i];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                      "Total: Rp${order.totalAmount.toStringAsFixed(0)}"),
                                  subtitle: Text(
                                      "Tanggal: ${DateHelper.formatDateTime(order.createdAt.toDate())}"),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'print') {
                                        await PrintService().printOrder(order);
                                      } else if (value == 'pdf') {
                                        final pdf =
                                            await PdfHelper.generatePdfNota(
                                                order);
                                        await Printing.layoutPdf(
                                            onLayout: (_) => pdf.save());
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'print',
                                        child: Text('Cetak Ulang'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'pdf',
                                        child: Text('Hanya PDF'),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.preview),
                                        onPressed: () {
                                          Get.dialog(
                                            AlertDialog(
                                              title: const Text("Preview Nota"),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children:
                                                    order.items.map((item) {
                                                  return ListTile(
                                                    title: Text(
                                                        "${item.name} ${item.size} ${item.isExtra ? '[Extra]' : ''}"),
                                                    subtitle: Text(
                                                        "${item.quantity} x ${item.price}"),
                                                    trailing: Text(
                                                        "Rp ${(item.quantity * item.price).toStringAsFixed(0)}"),
                                                  );
                                                }).toList(),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Get
                                                      .back(), // ✅ Menutup dialog
                                                  child: const Text("Tutup"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        label: const Text("Preview"),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
