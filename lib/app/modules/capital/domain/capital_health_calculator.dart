import 'package:postgetx/app/data/models/capital_health_summary.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';
import 'package:postgetx/app/modules/capital/domain/capital_protection_policy.dart';

abstract final class CapitalHealthCalculator {
  static CapitalHealthSummary calculate({
    required Iterable<CapitalLedgerEntry> entries,
    CapitalProtectionConfiguration configuration =
        CapitalProtectionConfiguration.defaults,
  }) {
    final ledger = entries.toList();

    final salesRevenue = ledger.fold<double>(
      0,
      (total, entry) => total + entry.salesRevenueDelta,
    );
    final restockRequirement = ledger.fold<double>(
      0,
      (total, entry) => total + entry.restockRequirementDelta,
    );
    final ownerWithdrawals =
        ledger.where((entry) => entry.isOwnerWithdrawal).fold<double>(
              0,
              (total, entry) => total + entry.withdrawalAmount,
            );
    final protectedCapitalUsed =
        ledger.where((entry) => entry.isOwnerWithdrawal).fold<double>(
              0,
              (total, entry) => total + entry.protectedCapitalImpact,
            );

    final allocation = CapitalProtectionPolicy.allocate(
      salesRevenue: salesRevenue > 0 ? salesRevenue : 0,
      costBasis: restockRequirement > 0 ? restockRequirement : 0,
      configuration: configuration,
    );

    final safeRemaining = allocation.safeToUse > ownerWithdrawals
        ? allocation.safeToUse - ownerWithdrawals
        : 0.0;

    final warningThreshold = allocation.safeToUse * .25;

    final status = protectedCapitalUsed > 0 || allocation.capitalDeficit > 0
        ? CapitalHealthStatus.highRisk
        : ownerWithdrawals > 0 && safeRemaining <= warningThreshold
            ? CapitalHealthStatus.warning
            : CapitalHealthStatus.safe;

    return CapitalHealthSummary(
      salesRevenue: salesRevenue,
      restockRequirement: restockRequirement,
      protectedCapital: allocation.protectedCapital,
      grossMargin: allocation.grossMargin,
      operationalReserve: allocation.operationalReserve,
      ownerWithdrawals: ownerWithdrawals,
      protectedCapitalUsed: protectedCapitalUsed,
      safeToUseBeforeWithdrawals: allocation.safeToUse,
      safeToUseRemaining: safeRemaining,
      capitalDeficit: allocation.capitalDeficit,
      status: status,
    );
  }
}
