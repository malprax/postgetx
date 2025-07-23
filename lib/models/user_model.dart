import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final String photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.photoUrl = '',
  });

  // Create UserModel from Map retrieved from Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    Timestamp? timestamp;
    if (map['createdAt'] != null && map['createdAt'] is Timestamp) {
      timestamp = map['createdAt'] as Timestamp;
    }

    return UserModel(
      uid: map['uid'] ?? id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: timestamp?.toDate(),
      photoUrl: map['photoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
