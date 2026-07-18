class LoyaltyConfiguration {
  const LoyaltyConfiguration({
    required this.isEnabled,
    required this.spendPerPoint,
    required this.redeemValuePerPoint,
    required this.minimumEligibleTransaction,
    required this.maximumRedemptionPercentage,
  });

  static const defaults = LoyaltyConfiguration(
    isEnabled: true,
    spendPerPoint: 10000,
    redeemValuePerPoint: 100,
    minimumEligibleTransaction: 10000,
    maximumRedemptionPercentage: 50,
  );

  final bool isEnabled;
  final double spendPerPoint;
  final double redeemValuePerPoint;
  final double minimumEligibleTransaction;
  final double maximumRedemptionPercentage;

  List<String> validate() {
    final errors = <String>[];

    if (!spendPerPoint.isFinite || spendPerPoint <= 0) {
      errors.add('Spending required per point must be greater than zero.');
    }

    if (!redeemValuePerPoint.isFinite || redeemValuePerPoint <= 0) {
      errors.add('Redemption value per point must be greater than zero.');
    }

    if (!minimumEligibleTransaction.isFinite ||
        minimumEligibleTransaction < 0) {
      errors.add('Minimum eligible transaction cannot be negative.');
    }

    if (!maximumRedemptionPercentage.isFinite ||
        maximumRedemptionPercentage <= 0 ||
        maximumRedemptionPercentage > 100) {
      errors.add(
        'Maximum redemption percentage must be between 1 and 100.',
      );
    }

    if (redeemValuePerPoint >= spendPerPoint) {
      errors.add(
        'Redemption value must remain lower than spending required per point.',
      );
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  LoyaltyConfiguration copyWith({
    bool? isEnabled,
    double? spendPerPoint,
    double? redeemValuePerPoint,
    double? minimumEligibleTransaction,
    double? maximumRedemptionPercentage,
  }) {
    return LoyaltyConfiguration(
      isEnabled: isEnabled ?? this.isEnabled,
      spendPerPoint: spendPerPoint ?? this.spendPerPoint,
      redeemValuePerPoint: redeemValuePerPoint ?? this.redeemValuePerPoint,
      minimumEligibleTransaction:
          minimumEligibleTransaction ?? this.minimumEligibleTransaction,
      maximumRedemptionPercentage:
          maximumRedemptionPercentage ?? this.maximumRedemptionPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'spendPerPoint': spendPerPoint,
      'redeemValuePerPoint': redeemValuePerPoint,
      'minimumEligibleTransaction': minimumEligibleTransaction,
      'maximumRedemptionPercentage': maximumRedemptionPercentage,
    };
  }

  factory LoyaltyConfiguration.fromMap(Map<dynamic, dynamic> map) {
    return LoyaltyConfiguration(
      isEnabled: map['isEnabled'] as bool? ?? defaults.isEnabled,
      spendPerPoint:
          (map['spendPerPoint'] as num?)?.toDouble() ?? defaults.spendPerPoint,
      redeemValuePerPoint: (map['redeemValuePerPoint'] as num?)?.toDouble() ??
          defaults.redeemValuePerPoint,
      minimumEligibleTransaction:
          (map['minimumEligibleTransaction'] as num?)?.toDouble() ??
              defaults.minimumEligibleTransaction,
      maximumRedemptionPercentage:
          (map['maximumRedemptionPercentage'] as num?)?.toDouble() ??
              defaults.maximumRedemptionPercentage,
    );
  }
}
