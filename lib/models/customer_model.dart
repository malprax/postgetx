import '../utils/customer_utils.dart';

class CustomerModel {
  final String id;

  final String membershipId;

  final String name;

  /// Nomor WhatsApp utama yang ditampilkan kepada pengguna.
  ///
  /// Contoh:
  /// - 081234567890
  /// - +6281234567890
  final String whatsapp;

  /// Nomor WhatsApp yang telah dinormalisasi untuk pencarian,
  /// pencocokan, dan validasi data unik.
  ///
  /// Contoh:
  /// - 6281234567890
  final String normalizedWhatsapp;

  /// Nomor telepon alternatif, rumah, kantor, atau nomor lainnya.
  final String phone;

  /// Nomor telepon alternatif yang telah dinormalisasi.
  final String normalizedPhone;

  final String email;

  final String address;

  final String notes;

  final DateTime? createdAt;

  final DateTime updatedAt;

  final bool isDeleted;

  final DateTime? deletedAt;

  final String deletedBy;

  final DateTime? restoredAt;

  final String restoredBy;

  CustomerModel({
    String? id,
    required this.membershipId,
    required this.name,
    required this.whatsapp,
    required this.normalizedWhatsapp,
    this.phone = '',
    this.normalizedPhone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy = '',
    this.restoredAt,
    this.restoredBy = '',
  })  : id = id ?? '',
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  factory CustomerModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    /*
     * Backward compatibility
     * ----------------------
     *
     * Pada schema lama, field `phone` digunakan sebagai nomor utama customer.
     * Setelah penambahan field WhatsApp, nomor utama lama dipindahkan menjadi
     * nomor WhatsApp.
     *
     * Schema lama:
     *
     * phone
     * normalizedPhone
     *
     * Schema baru:
     *
     * whatsapp
     * normalizedWhatsapp
     * phone
     * normalizedPhone
     */

    final hasWhatsappField = map.containsKey('whatsapp');

    final legacyPhone = _readString(map['phone']);

    final legacyNormalizedPhone = _normalizedNumber(
      value: map['normalizedPhone'],
      fallback: legacyPhone,
    );

    final whatsapp =
        hasWhatsappField ? _readString(map['whatsapp']) : legacyPhone;

    final normalizedWhatsapp = _normalizedNumber(
      value: map['normalizedWhatsapp'],
      fallback: hasWhatsappField ? whatsapp : legacyNormalizedPhone,
    );

    final phone = hasWhatsappField ? _readString(map['phone']) : '';

    final normalizedPhone = hasWhatsappField
        ? _normalizedNumber(
            value: map['normalizedPhone'],
            fallback: phone,
          )
        : '';

    final createdAt = _parseDateTime(map['createdAt']);

    return CustomerModel(
      id: _readString(map['id']).isNotEmpty ? _readString(map['id']) : id,
      membershipId: _readString(map['membershipId']),
      name: _readString(map['name']),
      whatsapp: whatsapp,
      normalizedWhatsapp: normalizedWhatsapp,
      phone: phone,
      normalizedPhone: normalizedPhone,
      email: _readString(map['email']),
      address: _readString(map['address']),
      notes: _readString(map['notes']),
      createdAt: createdAt,
      updatedAt: _parseDateTime(map['updatedAt']) ?? createdAt,
      isDeleted: _readBool(map['isDeleted']),
      deletedAt: _parseDateTime(map['deletedAt']),
      deletedBy: _readString(map['deletedBy']),
      restoredAt: _parseDateTime(map['restoredAt']),
      restoredBy: _readString(map['restoredBy']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'membershipId': membershipId,
      'name': name,
      'whatsapp': whatsapp,
      'normalizedWhatsapp': normalizedWhatsapp,
      'phone': phone,
      'normalizedPhone': normalizedPhone,
      'email': email,
      'address': address,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'restoredAt': restoredAt?.toIso8601String(),
      'restoredBy': restoredBy,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? membershipId,
    String? name,
    String? whatsapp,
    String? normalizedWhatsapp,
    String? phone,
    String? normalizedPhone,
    String? email,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    DateTime? restoredAt,
    String? restoredBy,
    bool clearCreatedAt = false,
    bool clearDeletedAt = false,
    bool clearRestoredAt = false,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      membershipId: membershipId ?? this.membershipId,
      name: name ?? this.name,
      whatsapp: whatsapp ?? this.whatsapp,
      normalizedWhatsapp: normalizedWhatsapp ?? this.normalizedWhatsapp,
      phone: phone ?? this.phone,
      normalizedPhone: normalizedPhone ?? this.normalizedPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: clearCreatedAt ? null : createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      restoredAt: clearRestoredAt ? null : restoredAt ?? this.restoredAt,
      restoredBy: restoredBy ?? this.restoredBy,
    );
  }

  /// Menghasilkan salinan model dengan nomor WhatsApp dan telepon
  /// yang sudah dinormalisasi ulang.
  ///
  /// Method ini berguna sebelum data dikirim ke repository atau disimpan.
  CustomerModel normalizeContactNumbers() {
    return copyWith(
      whatsapp: whatsapp.trim(),
      normalizedWhatsapp: CustomerUtils.normalizePhone(whatsapp),
      phone: phone.trim(),
      normalizedPhone: CustomerUtils.normalizePhone(phone),
    );
  }

  /// Menghasilkan salinan customer yang sudah ditandai sebagai dihapus.
  CustomerModel markDeleted({
    required DateTime deletedAt,
    required String deletedBy,
  }) {
    return copyWith(
      isDeleted: true,
      deletedAt: deletedAt,
      deletedBy: deletedBy.trim(),
      updatedAt: deletedAt,
      restoredBy: '',
      clearRestoredAt: true,
    );
  }

  /// Menghasilkan salinan customer yang dipulihkan dari Trash.
  CustomerModel markRestored({
    required DateTime restoredAt,
    required String restoredBy,
  }) {
    return copyWith(
      isDeleted: false,
      restoredAt: restoredAt,
      restoredBy: restoredBy.trim(),
      updatedAt: restoredAt,
      deletedBy: '',
      clearDeletedAt: true,
    );
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text = value?.toString().trim().toLowerCase();

    return text == 'true' || text == '1';
  }

  static String _normalizedNumber({
    required dynamic value,
    required String fallback,
  }) {
    final storedValue = _readString(value);

    if (storedValue.isNotEmpty) {
      return CustomerUtils.normalizePhone(storedValue);
    }

    return CustomerUtils.normalizePhone(fallback);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      );
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CustomerModel &&
        other.id == id &&
        other.membershipId == membershipId &&
        other.name == name &&
        other.whatsapp == whatsapp &&
        other.normalizedWhatsapp == normalizedWhatsapp &&
        other.phone == phone &&
        other.normalizedPhone == normalizedPhone &&
        other.email == email &&
        other.address == address &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isDeleted == isDeleted &&
        other.deletedAt == deletedAt &&
        other.deletedBy == deletedBy &&
        other.restoredAt == restoredAt &&
        other.restoredBy == restoredBy;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      membershipId,
      name,
      whatsapp,
      normalizedWhatsapp,
      phone,
      normalizedPhone,
      email,
      address,
      notes,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt,
      deletedBy,
      restoredAt,
      restoredBy,
    );
  }

  @override
  String toString() {
    return 'CustomerModel('
        'id: $id, '
        'membershipId: $membershipId, '
        'name: $name, '
        'whatsapp: $whatsapp, '
        'normalizedWhatsapp: $normalizedWhatsapp, '
        'phone: $phone, '
        'normalizedPhone: $normalizedPhone, '
        'email: $email, '
        'address: $address, '
        'notes: $notes, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'isDeleted: $isDeleted, '
        'deletedAt: $deletedAt, '
        'deletedBy: $deletedBy, '
        'restoredAt: $restoredAt, '
        'restoredBy: $restoredBy'
        ')';
  }
}
