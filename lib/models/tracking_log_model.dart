// TODO Implement this library.
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingLogModel {
  final String id;
  final String trackingId;
  final String status;
  final String note;
  final String updatedBy;
  final DateTime timestamp;

  TrackingLogModel({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.note,
    required this.updatedBy,
    required this.timestamp,
  });

  factory TrackingLogModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return TrackingLogModel(
      id: id ?? '',
      trackingId: map['trackingId'] ?? '',
      status: map['status'] ?? '',
      note: map['note'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trackingId': trackingId,
      'status': status,
      'note': note,
      'updatedBy': updatedBy,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
