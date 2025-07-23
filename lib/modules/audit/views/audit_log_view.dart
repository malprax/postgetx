import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/audit_log_controller.dart';
import '../widgets/log_tile.dart';

class AuditLogView extends StatelessWidget {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuditLogController());
    final scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isMoreLoading.value) {
        controller.fetchMoreLogs();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Audit')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 🔍 Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Cari log...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => controller.searchQuery.value = val,
              ),
            ),

            // 📤 Export & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Filter by UID'),
                      onChanged: (val) => controller.filterUserId.value = val,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null)
                        controller.filterDate.value = selected;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: "Export PDF",
                    onPressed: () => controller.exportToPdf(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    tooltip: "Export Excel",
                    onPressed: () => controller.exportToExcel(),
                  ),
                ],
              ),
            ),

            const Divider(),

            // 📋 Grouped Logs by Date
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: controller.groupedByDate.keys.length,
                itemBuilder: (context, index) {
                  final date = controller.groupedByDate.keys.toList()[index];
                  final logs = controller.groupedByDate[date]!;

                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                          .format(DateTime.parse(date)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: logs.map((log) => LogTile(log: log)).toList(),
                  );
                },
              ),
            ),

            if (controller.isMoreLoading.value)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      }),
    );
  }
}
