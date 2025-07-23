import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/audit_log_model.dart';

class AuditLogController extends GetxController {
  final logs = <AuditLogModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final searchQuery = ''.obs;

  final filterUserId = ''.obs;
  final filterDate = Rxn<DateTime>();
  DocumentSnapshot? lastDoc;
  bool hasMore = true;

  List<AuditLogModel> get filteredLogs {
    return logs.where((log) {
      final matchUser =
          filterUserId.value.isEmpty || log.performedBy == filterUserId.value;
      final matchDate = filterDate.value == null ||
          DateFormat('yyyy-MM-dd').format(log.timestamp) ==
              DateFormat('yyyy-MM-dd').format(filterDate.value!);
      final matchSearch = log.action
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          log.module?.toLowerCase().contains(searchQuery.value.toLowerCase()) ==
              true ||
          log.performedBy
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());
      return matchUser && matchDate && matchSearch;
    }).toList();
  }

  Map<String, List<AuditLogModel>> get groupedByDate {
    final map = <String, List<AuditLogModel>>{};
    for (var log in filteredLogs) {
      final date = DateFormat('yyyy-MM-dd').format(log.timestamp);
      map.putIfAbsent(date, () => []).add(log);
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialLogs();
  }

  Future<void> fetchInitialLogs() async {
    isLoading.value = true;
    logs.clear();
    lastDoc = null;
    hasMore = true;
    await fetchMoreLogs();
    isLoading.value = false;
  }

  Future<void> fetchMoreLogs() async {
    if (!hasMore || isMoreLoading.value) return;

    isMoreLoading.value = true;
    try {
      final query = FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(20);

      final snapshot = lastDoc != null
          ? await query.startAfterDocument(lastDoc!).get()
          : await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        logs.addAll(snapshot.docs.map((e) => AuditLogModel.fromMap(e.data())));
        if (snapshot.docs.length < 20) hasMore = false;
      } else {
        hasMore = false;
      }
    } catch (e) {
      print('Pagination error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Audit Logs'];
    sheet.appendRow(['Action', 'Target ID', 'User', 'Module', 'Timestamp']);

    for (var log in filteredLogs) {
      sheet.appendRow([
        log.action,
        log.targetId,
        log.performedBy,
        log.module ?? '-',
        DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp)
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await Printing.sharePdf(
          bytes: Uint8List.fromList(bytes), filename: 'audit_logs.xlsx');
    }
  }

  Future<void> exportToPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.ListView(
            children: filteredLogs.map((log) {
              return pw.Text(
                  "${log.timestamp} - ${log.action} (${log.module}) by ${log.performedBy}");
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
