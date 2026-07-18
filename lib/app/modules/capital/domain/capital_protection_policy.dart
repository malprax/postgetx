import 'package:postgetx/app/data/models/capital_allocation.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';

abstract final class CapitalProtectionPolicy {
  static CapitalAllocation allocate({
    required double salesRevenue,
    required double costBasis,
    CapitalProtectionConfiguration configuration =
        CapitalProtectionConfiguration.defaults,
  }) {
    if (!salesRevenue.isFinite || salesRevenue < 0) {
      throw const FormatException(
        'Sales revenue must be a non-negative finite value.',
      );
    }

    if (!costBasis.isFinite || costBasis < 0) {
      throw const FormatException(
        'Cost basis must be a non-negative finite value.',
      );
    }

    final configurationErrors = configuration.validate();

    if (configurationErrors.isNotEmpty) {
      throw FormatException(configurationErrors.join(' '));
    }

    final protectedCapital =
        salesRevenue < costBasis ? salesRevenue : costBasis;

    final grossMargin = salesRevenue - costBasis;
    final positiveMargin = grossMargin > 0 ? grossMargin : 0.0;

    final operationalReserve =
        positiveMargin * configuration.operationalReservePercentage / 100;

    final availableAfterReserve = positiveMargin - operationalReserve;

    final safeToUse = availableAfterReserve > configuration.minimumCashBuffer
        ? availableAfterReserve - configuration.minimumCashBuffer
        : 0.0;

    final capitalDeficit =
        costBasis > salesRevenue ? costBasis - salesRevenue : 0.0;

    return CapitalAllocation(
      salesRevenue: salesRevenue,
      restockRequirement: costBasis,
      protectedCapital: protectedCapital,
      grossMargin: grossMargin,
      operationalReserve: operationalReserve,
      safeToUse: safeToUse,
      capitalDeficit: capitalDeficit,
      minimumCashBuffer: configuration.minimumCashBuffer,
    );
  }
}
