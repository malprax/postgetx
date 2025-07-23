import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  // Simpan user baru ke Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // Ambil user berdasarkan UID
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  // Ubah status aktif/nonaktif
  Future<void> setUserActive(String uid, bool isActive) async {
    await _usersRef.doc(uid).update({'isActive': isActive});
  }

  // Ambil semua user
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
