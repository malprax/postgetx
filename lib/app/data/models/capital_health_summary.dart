enum CapitalHealthStatus {
  safe,
  warning,
  highRisk,
}

class CapitalHealthSummary {
  const CapitalHealthSummary({
    required this.salesRevenue,
    required this.restockRequirement,
    required this.protectedCapital,
    required this.grossMargin,
    required this.operationalReserve,
    required this.ownerWithdrawals,
    required this.protectedCapitalUsed,
    required this.safeToUseBeforeWithdrawals,
    required this.safeToUseRemaining,
    required this.capitalDeficit,
    required this.status,
  });

  final double salesRevenue;
  final double restockRequirement;
  final double protectedCapital;
  final double grossMargin;
  final double operationalReserve;
  final double ownerWithdrawals;
  final double protectedCapitalUsed;
  final double safeToUseBeforeWithdrawals;
  final double safeToUseRemaining;
  final double capitalDeficit;
  final CapitalHealthStatus status;

  bool get capitalIsSafe => status == CapitalHealthStatus.safe;

  String get statusLabel => switch (status) {
        CapitalHealthStatus.safe => 'Safe',
        CapitalHealthStatus.warning => 'Warning',
        CapitalHealthStatus.highRisk => 'High Risk',
      };
}
