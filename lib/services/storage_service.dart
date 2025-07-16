import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadUserPhoto(File file, String uid) async {
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
