import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/theme/app_spacing.dart';

class CapitalLedgerHistory extends StatelessWidget {
  const CapitalLedgerHistory({
    super.key,
    required this.entries,
  });

  final List<CapitalLedgerEntry> entries;

  String title(CapitalLedgerEntry entry) => switch (entry.type) {
        CapitalLedgerEntryType.saleAllocation => 'Sale Capital Allocation',
        CapitalLedgerEntryType.refundReversal => 'Refund Capital Reversal',
        CapitalLedgerEntryType.ownerWithdrawal => 'Owner Withdrawal',
      };

  IconData icon(CapitalLedgerEntry entry) => switch (entry.type) {
        CapitalLedgerEntryType.saleAllocation => Icons.point_of_sale_outlined,
        CapitalLedgerEntryType.refundReversal => Icons.undo_outlined,
        CapitalLedgerEntryType.ownerWithdrawal => Icons.payments_outlined,
      };

  Color color(CapitalLedgerEntry entry) => switch (entry.type) {
        CapitalLedgerEntryType.saleAllocation => Colors.green,
        CapitalLedgerEntryType.refundReversal => Colors.orange,
        CapitalLedgerEntryType.ownerWithdrawal =>
          entry.usesProtectedCapital ? Colors.red : Colors.blue,
      };

  String amount(CapitalLedgerEntry entry) => switch (entry.type) {
        CapitalLedgerEntryType.saleAllocation =>
          RupiahFormatter.format(entry.restockRequirementDelta),
        CapitalLedgerEntryType.refundReversal =>
          RupiahFormatter.format(entry.restockRequirementDelta),
        CapitalLedgerEntryType.ownerWithdrawal =>
          RupiahFormatter.format(entry.withdrawalAmount),
      };

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Card(
      key: const ValueKey('capital-ledger-history'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Capital Ledger History',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No capital activity recorded yet.',
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final entry = sorted[index];
                  final entryColor = color(entry);

                  return ListTile(
                    key: ValueKey('capital-entry-${entry.id}'),
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: entryColor.withValues(alpha: .12),
                      foregroundColor: entryColor,
                      child: Icon(icon(entry)),
                    ),
                    title: Text(title(entry)),
                    subtitle: Text(
                      [
                        if (entry.orderId.isNotEmpty) 'Order: ${entry.orderId}',
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(entry.createdAt),
                        if (entry.reason.isNotEmpty) entry.reason,
                        if (entry.usesProtectedCapital)
                          'Protected capital used: '
                              '${RupiahFormatter.format(entry.protectedCapitalImpact)}',
                      ].join(' · '),
                    ),
                    trailing: Text(
                      amount(entry),
                      style: TextStyle(
                        color: entryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
