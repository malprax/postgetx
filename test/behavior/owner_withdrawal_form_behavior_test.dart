import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_health_summary.dart';
import 'package:postgetx/app/modules/capital/widgets/capital_health_summary_card.dart';

void main() {
  const summary = CapitalHealthSummary(
    salesRevenue: 13500,
    restockRequirement: 9000,
    protectedCapital: 9000,
    grossMargin: 4500,
    operationalReserve: 900,
    ownerWithdrawals: 0,
    protectedCapitalUsed: 0,
    safeToUseBeforeWithdrawals: 3600,
    safeToUseRemaining: 3600,
    capitalDeficit: 0,
    status: CapitalHealthStatus.safe,
  );

  testWidgets(
    'Given a presentational withdrawal form, '
    'When an amount exceeds safe profit, '
    'Then protected capital impact is previewed before saving',
    (tester) async {
      double? submittedAmount;
      String? submittedReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerWithdrawalDialog(
              summary: summary,
              onSubmit: (amount, reason) async {
                submittedAmount = amount;
                submittedReason = reason;
                return false;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(
          const ValueKey('owner-withdrawal-amount'),
        ),
        '5000',
      );
      await tester.enterText(
        find.byKey(
          const ValueKey('owner-withdrawal-reason'),
        ),
        'Emergency personal use',
      );
      await tester.pump();

      expect(
        find.textContaining('uses Rp1.400'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('save-owner-withdrawal'),
        ),
      );
      await tester.pump();

      expect(submittedAmount, 5000);
      expect(submittedReason, 'Emergency personal use');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given invalid withdrawal details, '
    'When record is pressed, '
    'Then validation blocks the callback',
    (tester) async {
      var submitCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OwnerWithdrawalDialog(
              summary: summary,
              onSubmit: (_, __) async {
                submitCount++;
                return true;
              },
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(
          const ValueKey('save-owner-withdrawal'),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'Withdrawal amount must be greater than zero.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Withdrawal reason is required.'),
        findsOneWidget,
      );
      expect(submitCount, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
