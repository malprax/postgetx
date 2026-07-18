import 'package:flutter/material.dart';
import 'package:postgetx/app/core/helpers/rupiah_formatter.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';

class CustomerLoyaltyTierSummary extends StatelessWidget {
  const CustomerLoyaltyTierSummary({
    super.key,
    required this.profile,
    this.compact = false,
  });

  final CustomerLoyaltyTierProfile profile;
  final bool compact;

  Color _tierColor(BuildContext context) {
    return switch (profile.tier) {
      LoyaltyTier.member => Theme.of(context).colorScheme.secondary,
      LoyaltyTier.silver => const Color(0xFF64748B),
      LoyaltyTier.gold => const Color(0xFFD97706),
    };
  }

  IconData get _tierIcon => switch (profile.tier) {
        LoyaltyTier.member => Icons.person_outline,
        LoyaltyTier.silver => Icons.workspace_premium_outlined,
        LoyaltyTier.gold => Icons.emoji_events_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(context);

    if (compact) {
      return Chip(
        key: ValueKey('customer-tier-${profile.customerId}'),
        avatar: Icon(_tierIcon, size: 18, color: color),
        label: Text(profile.tier.label),
        side: BorderSide(color: color.withValues(alpha: 0.45)),
      );
    }

    return Card(
      key: ValueKey('customer-tier-summary-${profile.customerId}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Icon(_tierIcon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.tier.label} Customer',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lifetime spending: '
                    '${RupiahFormatter.format(
                      profile.lifetimeEligibleSpend,
                    )}',
                  ),
                  Text(
                    'Points multiplier: '
                    'x${profile.pointsMultiplier}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
