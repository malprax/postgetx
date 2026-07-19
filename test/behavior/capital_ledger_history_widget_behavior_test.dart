import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/modules/capital/widgets/capital_ledger_history.dart';

void main() {
  testWidgets(
    'Given presentational capital entries, '
    'When history is shown, '
    'Then sale refund and risky withdrawal are visible without Hive or GetX',
    (tester) async {
      final entries = [
        CapitalLedgerEntry(
          id: 'sale',
          orderId: 'ORDER-1',
          type: CapitalLedgerEntryType.saleAllocation,
          salesRevenueDelta: 13500,
          restockRequirementDelta: 9000,
          grossMarginDelta: 4500,
          createdAt: DateTime(2026, 7, 19, 10),
          actorId: 'owner',
          reason: 'Protected capital',
        ),
        CapitalLedgerEntry(
          id: 'refund',
          orderId: 'ORDER-1',
          type: CapitalLedgerEntryType.refundReversal,
          salesRevenueDelta: -13500,
          restockRequirementDelta: -9000,
          grossMarginDelta: -4500,
          createdAt: DateTime(2026, 7, 19, 11),
          actorId: 'owner',
          reason: 'Customer refund',
          reversesEntryId: 'sale',
        ),
        CapitalLedgerEntry(
          id: 'withdrawal',
          orderId: '',
          type: CapitalLedgerEntryType.ownerWithdrawal,
          salesRevenueDelta: 0,
          restockRequirementDelta: 0,
          grossMarginDelta: 0,
          withdrawalAmount: 5000,
          protectedCapitalImpact: 1400,
          createdAt: DateTime(2026, 7, 19, 12),
          actorId: 'owner',
          reason: 'Personal consumption',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CapitalLedgerHistory(entries: entries),
            ),
          ),
        ),
      );

      expect(find.text('Capital Ledger History'), findsOneWidget);
      expect(find.text('Sale Capital Allocation'), findsOneWidget);
      expect(find.text('Refund Capital Reversal'), findsOneWidget);
      expect(find.text('Owner Withdrawal'), findsOneWidget);
      expect(
        find.textContaining('Protected capital used'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given no capital entries, When history is shown, '
    'Then a safe empty state is visible',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CapitalLedgerHistory(entries: []),
          ),
        ),
      );

      expect(
        find.text('No capital activity recorded yet.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
