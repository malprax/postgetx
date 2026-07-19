import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_health_summary.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/modules/capital/domain/capital_health_calculator.dart';

CapitalLedgerEntry sale() => CapitalLedgerEntry(
      id: 'sale',
      orderId: 'order',
      type: CapitalLedgerEntryType.saleAllocation,
      salesRevenueDelta: 13500,
      restockRequirementDelta: 9000,
      grossMarginDelta: 4500,
      createdAt: DateTime(2026),
      actorId: 'owner',
    );

CapitalLedgerEntry withdrawal({
  required double amount,
  required double protectedImpact,
}) =>
    CapitalLedgerEntry(
      id: 'withdrawal-$amount',
      orderId: '',
      type: CapitalLedgerEntryType.ownerWithdrawal,
      salesRevenueDelta: 0,
      restockRequirementDelta: 0,
      grossMarginDelta: 0,
      withdrawalAmount: amount,
      protectedCapitalImpact: protectedImpact,
      createdAt: DateTime(2026),
      actorId: 'owner',
      reason: 'Personal use',
    );

void main() {
  test(
    'Given protected capital and healthy remaining margin, '
    'When health is calculated, Then the business is safe',
    () {
      final summary = CapitalHealthCalculator.calculate(
        entries: [
          sale(),
          withdrawal(amount: 1000, protectedImpact: 0),
        ],
      );

      expect(summary.protectedCapital, 9000);
      expect(summary.safeToUseBeforeWithdrawals, 3600);
      expect(summary.safeToUseRemaining, 2600);
      expect(summary.status, CapitalHealthStatus.safe);
    },
  );

  test(
    'Given most safe profit was withdrawn, '
    'When health is calculated, Then the business is warned',
    () {
      final summary = CapitalHealthCalculator.calculate(
        entries: [
          sale(),
          withdrawal(amount: 3000, protectedImpact: 0),
        ],
      );

      expect(summary.safeToUseRemaining, 600);
      expect(summary.status, CapitalHealthStatus.warning);
    },
  );

  test(
    'Given an owner withdrawal consumed protected capital, '
    'When health is calculated, Then risk is high',
    () {
      final summary = CapitalHealthCalculator.calculate(
        entries: [
          sale(),
          withdrawal(amount: 5000, protectedImpact: 1400),
        ],
      );

      expect(summary.safeToUseRemaining, 0);
      expect(summary.protectedCapitalUsed, 1400);
      expect(summary.status, CapitalHealthStatus.highRisk);
    },
  );
}
