abstract final class LoyaltyPointsPolicy {
  static const double spendPerPoint = 10000;
  static const double redeemValuePerPoint = 100;

  static int earnedPoints(
    double eligibleAmount, {
    bool isEnabled = true,
    double spendingRequired = spendPerPoint,
    double minimumEligibleTransaction = 0,
  }) {
    if (!isEnabled ||
        !eligibleAmount.isFinite ||
        eligibleAmount <= 0 ||
        !spendingRequired.isFinite ||
        spendingRequired <= 0 ||
        !minimumEligibleTransaction.isFinite ||
        minimumEligibleTransaction < 0 ||
        eligibleAmount < minimumEligibleTransaction) {
      return 0;
    }

    return eligibleAmount ~/ spendingRequired;
  }

  static double redemptionValue(
    int points, {
    bool isEnabled = true,
    double valuePerPoint = redeemValuePerPoint,
  }) {
    if (!isEnabled ||
        points <= 0 ||
        !valuePerPoint.isFinite ||
        valuePerPoint <= 0) {
      return 0;
    }

    return points * valuePerPoint;
  }

  static int maximumRedeemablePoints({
    required int availablePoints,
    required double payableAmount,
    required double valuePerPoint,
    required double maximumRedemptionPercentage,
    bool isEnabled = true,
  }) {
    if (!isEnabled ||
        availablePoints <= 0 ||
        !payableAmount.isFinite ||
        payableAmount <= 0 ||
        !valuePerPoint.isFinite ||
        valuePerPoint <= 0 ||
        !maximumRedemptionPercentage.isFinite ||
        maximumRedemptionPercentage <= 0 ||
        maximumRedemptionPercentage > 100) {
      return 0;
    }

    final maximumDiscount = payableAmount * maximumRedemptionPercentage / 100;

    final pointsAllowedByTransaction =
        (maximumDiscount / valuePerPoint).floor();

    return pointsAllowedByTransaction.clamp(0, availablePoints);
  }

  static int balance(Iterable<int> deltas) {
    return deltas.fold<int>(0, (total, delta) => total + delta);
  }
}
