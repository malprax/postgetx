import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_health_summary.dart';
import 'package:postgetx/app/modules/capital/widgets/capital_health_summary_card.dart';

void main() {
  testWidgets(
    'Given a presentational capital summary, '
    'When high-risk data is shown, '
    'Then protected capital leakage is visible without Hive or GetX',
    (tester) async {
      const summary = CapitalHealthSummary(
        salesRevenue: 13500,
        restockRequirement: 9000,
        protectedCapital: 9000,
        grossMargin: 4500,
        operationalReserve: 900,
        ownerWithdrawals: 5000,
        protectedCapitalUsed: 1400,
        safeToUseBeforeWithdrawals: 3600,
        safeToUseRemaining: 0,
        capitalDeficit: 0,
        status: CapitalHealthStatus.highRisk,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CapitalHealthSummaryCard(summary: summary),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('capital-health-summary')),
        findsOneWidget,
      );
      expect(find.text('Capital Protection'), findsOneWidget);
      expect(find.text('High Risk'), findsOneWidget);
      expect(find.text('Protected Capital Used'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
