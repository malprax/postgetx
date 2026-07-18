import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/core/services/loyalty_points_policy.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';

void main() {
  group('loyalty points policy', () {
    test('earns one point for every Rp10.000 eligible spend', () {
      expect(LoyaltyPointsPolicy.earnedPoints(9999), 0);
      expect(LoyaltyPointsPolicy.earnedPoints(10000), 1);
      expect(LoyaltyPointsPolicy.earnedPoints(25999), 2);
      expect(LoyaltyPointsPolicy.earnedPoints(100000), 10);
    });

    test('rejects invalid eligible amounts', () {
      expect(LoyaltyPointsPolicy.earnedPoints(0), 0);
      expect(LoyaltyPointsPolicy.earnedPoints(-10000), 0);
      expect(LoyaltyPointsPolicy.earnedPoints(double.nan), 0);
      expect(LoyaltyPointsPolicy.earnedPoints(double.infinity), 0);
    });

    test('calculates redemption value and ledger balance', () {
      expect(LoyaltyPointsPolicy.redemptionValue(10), 1000);
      expect(LoyaltyPointsPolicy.redemptionValue(0), 0);
      expect(LoyaltyPointsPolicy.balance([10, -3, 2, -1]), 8);
    });
  });

  group('loyalty ledger entry', () {
    test('round-trips through local storage map', () {
      final createdAt = DateTime.utc(2026, 7, 18, 10, 30);
      final entry = LoyaltyLedgerEntry(
        id: 'loyalty-1',
        customerId: 'customer-1',
        type: LoyaltyEntryType.earned,
        pointsDelta: 5,
        createdAt: createdAt,
        actorId: 'demo-owner',
        orderId: 'order-1',
        reason: 'Completed sale',
      );

      final restored = LoyaltyLedgerEntry.fromMap(entry.toMap());

      expect(restored.id, entry.id);
      expect(restored.customerId, entry.customerId);
      expect(restored.type, LoyaltyEntryType.earned);
      expect(restored.pointsDelta, 5);
      expect(restored.createdAt, createdAt);
      expect(restored.actorId, 'demo-owner');
      expect(restored.orderId, 'order-1');
      expect(restored.reason, 'Completed sale');
    });

    test('centralizes supported ledger entry types', () {
      expect(
        LoyaltyEntryType.values,
        containsAll(<String>{
          LoyaltyEntryType.earned,
          LoyaltyEntryType.redeemed,
          LoyaltyEntryType.reversed,
          LoyaltyEntryType.adjusted,
          LoyaltyEntryType.expired,
        }),
      );
    });
  });
}
