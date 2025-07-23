import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String action;
  final String targetId;
  final String performedBy;
  final DateTime timestamp;
  final String? module;

  AuditLogModel({
    required this.action,
    required this.targetId,
    required this.performedBy,
    required this.timestamp,
    this.module,
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      action: map['action'] ?? '',
      targetId: map['targetId'] ?? '',
      performedBy: map['performedBy'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      module: map['module'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'targetId': targetId,
      'performedBy': performedBy,
      'timestamp': timestamp,
      'module': module,
    };
  }
}
