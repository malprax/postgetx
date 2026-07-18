abstract final class LoyaltyEntryType {
  static const earned = 'earned';
  static const redeemed = 'redeemed';
  static const reversed = 'reversed';
  static const restored = 'restored';
  static const adjusted = 'adjusted';
  static const expired = 'expired';

  static const values = <String>{
    earned,
    redeemed,
    reversed,
    restored,
    adjusted,
    expired,
  };
}

class LoyaltyLedgerEntry {
  const LoyaltyLedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.pointsDelta,
    required this.createdAt,
    required this.actorId,
    this.orderId,
    this.reason = '',
  });

  final String id;
  final String customerId;
  final String type;
  final int pointsDelta;
  final DateTime createdAt;
  final String actorId;
  final String? orderId;
  final String reason;

  factory LoyaltyLedgerEntry.fromMap(Map<String, dynamic> map) {
    return LoyaltyLedgerEntry(
      id: map['id']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      pointsDelta: (map['pointsDelta'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(
            map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      actorId: map['actorId']?.toString() ?? '',
      orderId: map['orderId']?.toString(),
      reason: map['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'customerId': customerId,
        'type': type,
        'pointsDelta': pointsDelta,
        'createdAt': createdAt.toIso8601String(),
        'actorId': actorId,
        'orderId': orderId,
        'reason': reason,
      };
}
