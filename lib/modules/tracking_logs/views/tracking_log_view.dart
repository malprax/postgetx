import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrackingLogView extends StatelessWidget {
  final String trackingId;

  const TrackingLogView({super.key, required this.trackingId});

  @override
  Widget build(BuildContext context) {
    final logStream = FirebaseFirestore.instance
        .collection('tracking_logs')
        .where('trackingId', isEqualTo: trackingId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Tracking')),
      body: StreamBuilder<QuerySnapshot>(
        stream: logStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final logs = snapshot.data!.docs;

          if (logs.isEmpty)
            return const Center(child: Text('Belum ada histori'));

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final timestamp = log['timestamp']?.toDate();
              final formatted = timestamp != null
                  ? DateFormat('dd MMM yyyy – HH:mm').format(timestamp)
                  : '-';

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(log['status'] ?? '-'),
                subtitle:
                    Text('${log['note'] ?? ''}\nOleh: ${log['updatedBy']}'),
                trailing: Text(formatted),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
