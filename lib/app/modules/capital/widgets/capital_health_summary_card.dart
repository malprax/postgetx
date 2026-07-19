import 'package:flutter/material.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';
import 'package:postgetx/app/data/models/capital_health_summary.dart';
import 'package:postgetx/app/theme/app_radius.dart';
import 'package:postgetx/app/theme/app_spacing.dart';

class CapitalHealthSummaryCard extends StatelessWidget {
  const CapitalHealthSummaryCard({
    super.key,
    required this.summary,
    this.onRecordWithdrawal,
  });

  final CapitalHealthSummary summary;
  final VoidCallback? onRecordWithdrawal;

  Color get statusColor => switch (summary.status) {
        CapitalHealthStatus.safe => Colors.green,
        CapitalHealthStatus.warning => Colors.orange,
        CapitalHealthStatus.highRisk => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('capital-health-summary'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Capital Protection',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (onRecordWithdrawal != null) ...[
                  FilledButton.tonalIcon(
                    key: const ValueKey(
                      'open-owner-withdrawal',
                    ),
                    onPressed: onRecordWithdrawal,
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Owner Withdrawal'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Container(
                  key: const ValueKey('capital-health-status'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    summary.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              children: [
                _Metric(
                  label: 'Protected Restock Capital',
                  value: summary.protectedCapital,
                ),
                _Metric(
                  label: 'Gross Margin',
                  value: summary.grossMargin,
                ),
                _Metric(
                  label: 'Operational Reserve',
                  value: summary.operationalReserve,
                ),
                _Metric(
                  label: 'Owner Withdrawals',
                  value: summary.ownerWithdrawals,
                ),
                _Metric(
                  label: 'Safe to Use',
                  value: summary.safeToUseRemaining,
                ),
                _Metric(
                  label: 'Protected Capital Used',
                  value: summary.protectedCapitalUsed,
                  warning: summary.protectedCapitalUsed > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.warning = false,
  });

  final String label;
  final double value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 3),
          Text(
            RupiahFormatter.format(value),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: warning ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerWithdrawalDialog extends StatefulWidget {
  const OwnerWithdrawalDialog({
    super.key,
    required this.summary,
    required this.onSubmit,
  });

  final CapitalHealthSummary summary;
  final Future<bool> Function(
    double amount,
    String reason,
  ) onSubmit;

  @override
  State<OwnerWithdrawalDialog> createState() => _OwnerWithdrawalDialogState();
}

class _OwnerWithdrawalDialogState extends State<OwnerWithdrawalDialog> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  bool submitting = false;

  double get amount => double.tryParse(amountController.text.trim()) ?? 0;

  double get protectedImpact {
    final difference = amount - widget.summary.safeToUseRemaining;
    return difference > 0 ? difference : 0;
  }

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false) || submitting) {
      return;
    }

    setState(() => submitting = true);

    final saved = await widget.onSubmit(
      amount,
      reasonController.text.trim(),
    );

    if (!mounted) return;

    setState(() => submitting = false);

    if (saved) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final impact = protectedImpact;

    return AlertDialog(
      title: const Text('Record Owner Withdrawal'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Safe to use: '
                '${RupiahFormatter.format(widget.summary.safeToUseRemaining)}',
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                key: const ValueKey('owner-withdrawal-amount'),
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Withdrawal Amount',
                  hintText: 'Example: 500000',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');

                  if (parsed == null || !parsed.isFinite || parsed <= 0) {
                    return 'Withdrawal amount must be greater than zero.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                key: const ValueKey('owner-withdrawal-reason'),
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Example: Owner household allowance',
                ),
                maxLines: 2,
                validator: (value) => value?.trim().isNotEmpty == true
                    ? null
                    : 'Withdrawal reason is required.',
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                key: const ValueKey('withdrawal-risk-preview'),
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: impact > 0
                      ? Colors.red.withValues(alpha: .12)
                      : Colors.green.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  impact > 0
                      ? 'Warning: this uses '
                          '${RupiahFormatter.format(impact)} '
                          'of protected capital.'
                      : 'This withdrawal remains within safe profit.',
                  style: TextStyle(
                    color: impact > 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('save-owner-withdrawal'),
          onPressed: submitting ? null : submit,
          child: Text(submitting ? 'Saving...' : 'Record'),
        ),
      ],
    );
  }
}
