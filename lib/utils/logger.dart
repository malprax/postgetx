import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> logAudit({
  required String action,
  required String targetId,
  required String description,
  String module = '',
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance.collection('audit_logs').add({
    'action': action,
    'targetId': targetId,
    'description': description,
    'module': module,
    'performedBy': uid,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Future<void> logTracking({
  required String trackingId,
  required String status,
  required String note,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  await FirebaseFirestore.instance.collection('tracking_logs').add({
    'trackingId': trackingId,
    'status': status,
    'note': note,
    'updatedBy': uid,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
