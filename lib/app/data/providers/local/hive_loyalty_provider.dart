import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';

class HiveLoyaltyProvider {
  HiveLoyaltyProvider(this._box);

  static const storageKey = 'loyaltyLedger';

  final Box<dynamic> _box;

  List<LoyaltyLedgerEntry> readEntries() {
    final values = _box.get(
      storageKey,
      defaultValue: const <dynamic>[],
    ) as List;

    return values
        .map(
          (value) => LoyaltyLedgerEntry.fromMap(
            Map<String, dynamic>.from(value as Map),
          ),
        )
        .toList();
  }

  Future<void> writeEntries(
    Iterable<LoyaltyLedgerEntry> entries,
  ) {
    return _box.put(
      storageKey,
      entries.map((entry) => entry.toMap()).toList(),
    );
  }

  Future<void> clear() => _box.put(
        storageKey,
        const <dynamic>[],
      );
}
