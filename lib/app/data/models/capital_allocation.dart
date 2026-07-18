class CapitalAllocation {
  const CapitalAllocation({
    required this.salesRevenue,
    required this.restockRequirement,
    required this.protectedCapital,
    required this.grossMargin,
    required this.operationalReserve,
    required this.safeToUse,
    required this.capitalDeficit,
    required this.minimumCashBuffer,
  });

  final double salesRevenue;
  final double restockRequirement;
  final double protectedCapital;
  final double grossMargin;
  final double operationalReserve;
  final double safeToUse;
  final double capitalDeficit;
  final double minimumCashBuffer;

  bool get capitalIsSafe => capitalDeficit == 0;

  double get allocatedCash => protectedCapital + operationalReserve + safeToUse;
}
