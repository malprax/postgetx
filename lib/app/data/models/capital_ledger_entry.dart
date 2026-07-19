enum CapitalLedgerEntryType {
  saleAllocation,
  refundReversal,
}

class CapitalLedgerEntry {
  const CapitalLedgerEntry({
    required this.id,
    required this.orderId,
    required this.type,
    required this.salesRevenueDelta,
    required this.restockRequirementDelta,
    required this.grossMarginDelta,
    required this.createdAt,
    required this.actorId,
    this.reason = '',
    this.reversesEntryId,
  });

  static const storageKey = 'capitalLedger';

  final String id;
  final String orderId;
  final CapitalLedgerEntryType type;
  final double salesRevenueDelta;
  final double restockRequirementDelta;
  final double grossMarginDelta;
  final DateTime createdAt;
  final String actorId;
  final String reason;
  final String? reversesEntryId;

  bool get isReversal => type == CapitalLedgerEntryType.refundReversal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'type': type.name,
      'salesRevenueDelta': salesRevenueDelta,
      'restockRequirementDelta': restockRequirementDelta,
      'grossMarginDelta': grossMarginDelta,
      'createdAt': createdAt.toIso8601String(),
      'actorId': actorId,
      'reason': reason,
      'reversesEntryId': reversesEntryId,
    };
  }

  factory CapitalLedgerEntry.fromMap(Map<String, dynamic> map) {
    final typeName = map['type']?.toString();

    return CapitalLedgerEntry(
      id: map['id']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      type: CapitalLedgerEntryType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => CapitalLedgerEntryType.saleAllocation,
      ),
      salesRevenueDelta: (map['salesRevenueDelta'] as num?)?.toDouble() ?? 0,
      restockRequirementDelta:
          (map['restockRequirementDelta'] as num?)?.toDouble() ?? 0,
      grossMarginDelta: (map['grossMarginDelta'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      actorId: map['actorId']?.toString() ?? 'system',
      reason: map['reason']?.toString() ?? '',
      reversesEntryId: map['reversesEntryId']?.toString(),
    );
  }
}
