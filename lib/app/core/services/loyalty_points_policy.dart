abstract final class LoyaltyPointsPolicy {
  static const double spendPerPoint = 10000;
  static const double redeemValuePerPoint = 100;

  static int earnedPoints(double eligibleAmount) {
    if (!eligibleAmount.isFinite || eligibleAmount <= 0) return 0;
    return eligibleAmount ~/ spendPerPoint;
  }

  static double redemptionValue(int points) {
    if (points <= 0) return 0;
    return points * redeemValuePerPoint;
  }

  static int balance(Iterable<int> deltas) {
    return deltas.fold<int>(0, (total, delta) => total + delta);
  }
}
