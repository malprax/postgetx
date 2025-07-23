import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> exportToExcel(List<Map<String, dynamic>> data) async {
  final excel = Excel.createExcel();
  final sheet = excel['Riwayat'];

  // Header
  sheet.appendRow(['Status', 'Catatan', 'Oleh', 'Waktu']);

  for (var row in data) {
    final time = (row['timestamp'] as Timestamp?)?.toDate().toString() ?? '-';
    sheet.appendRow([
      row['status'] ?? '',
      row['note'] ?? '',
      row['updatedBy'] ?? '',
      time,
    ]);
  }

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/riwayat_tracking.xlsx');
  await file.writeAsBytes(excel.encode()!);

  Get.snackbar("Sukses", "File diekspor ke ${file.path}",
      snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
}
