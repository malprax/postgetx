import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/audit_log_model.dart';

class LogTile extends StatelessWidget {
  final AuditLogModel log;

  const LogTile({super.key, required this.log});

  IconData getModuleIcon(String? module) {
    switch (module) {
      case 'users':
        return Icons.person;
      case 'orders':
        return Icons.receipt;
      case 'stock':
        return Icons.inventory;
      case 'tracking':
        return Icons.local_shipping;
      default:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(getModuleIcon(log.module), color: Colors.indigo),
      title: Text(log.action),
      subtitle: Text(
        'Target: ${log.targetId}\nBy: ${log.performedBy}\nModule: ${log.module ?? "-"}',
      ),
      trailing: Text(
        DateFormat('dd MMM yyyy\nHH:mm').format(log.timestamp),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
