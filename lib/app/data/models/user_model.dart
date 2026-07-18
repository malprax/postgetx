class UserModel {
  final String id;
  String get uid => id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final String passwordHash;
  final String photoUrl;

  UserModel({
    String? id,
    String? uid,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    this.createdAt,
    DateTime? updatedAt,
    this.passwordHash = '',
    this.photoUrl = '',
  })  : id = id ?? uid ?? '',
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  // Create a user from locally persisted map data.
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? map['uid'] ?? id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
      passwordHash: map['passwordHash']?.toString() ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': id,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'passwordHash': passwordHash,
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
    DateTime? updatedAt,
    String? passwordHash,
    String? photoUrl,
  }) {
    return UserModel(
      id: uid ?? id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordHash: passwordHash ?? this.passwordHash,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
