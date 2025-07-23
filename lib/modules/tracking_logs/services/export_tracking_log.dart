import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> logTrackingStatus({
  required String trackingId,
  required String newStatus,
  String? note,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw Exception("Not logged in");

  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final role = userDoc.data()?['role'];
  final isActive = userDoc.data()?['isActive'] ?? false;

  // Validasi role
  if ((role != 'kurir' && role != 'admin') || !isActive) {
    throw Exception("Kamu tidak memiliki izin mencatat log");
  }

  await FirebaseFirestore.instance.collection('tracking_logs').add({
    'trackingId': trackingId,
    'status': newStatus,
    'updatedBy': uid,
    'timestamp': FieldValue.serverTimestamp(),
    'note': note ?? '',
  });
}
