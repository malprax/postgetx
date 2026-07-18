enum LoyaltyTier {
  member,
  silver,
  gold;

  String get label => switch (this) {
        LoyaltyTier.member => 'Member',
        LoyaltyTier.silver => 'Silver',
        LoyaltyTier.gold => 'Gold',
      };
}

class LoyaltyTierRules {
  const LoyaltyTierRules({
    required this.silverMinimumSpend,
    required this.goldMinimumSpend,
    required this.memberPointsMultiplier,
    required this.silverPointsMultiplier,
    required this.goldPointsMultiplier,
  });

  static const defaults = LoyaltyTierRules(
    silverMinimumSpend: 1000000,
    goldMinimumSpend: 5000000,
    memberPointsMultiplier: 1,
    silverPointsMultiplier: 1.25,
    goldPointsMultiplier: 1.5,
  );

  final double silverMinimumSpend;
  final double goldMinimumSpend;
  final double memberPointsMultiplier;
  final double silverPointsMultiplier;
  final double goldPointsMultiplier;

  List<String> validate() {
    final errors = <String>[];

    if (!silverMinimumSpend.isFinite || silverMinimumSpend <= 0) {
      errors.add('Silver minimum spending must be greater than zero.');
    }

    if (!goldMinimumSpend.isFinite || goldMinimumSpend <= silverMinimumSpend) {
      errors.add(
        'Gold minimum spending must be greater than Silver.',
      );
    }

    final multipliers = {
      'Member': memberPointsMultiplier,
      'Silver': silverPointsMultiplier,
      'Gold': goldPointsMultiplier,
    };

    for (final entry in multipliers.entries) {
      if (!entry.value.isFinite || entry.value < 1 || entry.value > 2) {
        errors.add(
          '${entry.key} points multiplier must be between 1 and 2.',
        );
      }
    }

    if (silverPointsMultiplier < memberPointsMultiplier) {
      errors.add(
        'Silver multiplier cannot be lower than Member.',
      );
    }

    if (goldPointsMultiplier < silverPointsMultiplier) {
      errors.add(
        'Gold multiplier cannot be lower than Silver.',
      );
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;

  LoyaltyTier resolve(double lifetimeEligibleSpend) {
    if (!lifetimeEligibleSpend.isFinite ||
        lifetimeEligibleSpend < silverMinimumSpend) {
      return LoyaltyTier.member;
    }

    if (lifetimeEligibleSpend < goldMinimumSpend) {
      return LoyaltyTier.silver;
    }

    return LoyaltyTier.gold;
  }

  double multiplierFor(LoyaltyTier tier) {
    return switch (tier) {
      LoyaltyTier.member => memberPointsMultiplier,
      LoyaltyTier.silver => silverPointsMultiplier,
      LoyaltyTier.gold => goldPointsMultiplier,
    };
  }

  int rewardedPoints({
    required int basePoints,
    required LoyaltyTier tier,
  }) {
    if (basePoints <= 0) return 0;
    return (basePoints * multiplierFor(tier)).floor();
  }

  Map<String, dynamic> toMap() {
    return {
      'silverMinimumSpend': silverMinimumSpend,
      'goldMinimumSpend': goldMinimumSpend,
      'memberPointsMultiplier': memberPointsMultiplier,
      'silverPointsMultiplier': silverPointsMultiplier,
      'goldPointsMultiplier': goldPointsMultiplier,
    };
  }

  factory LoyaltyTierRules.fromMap(Map<dynamic, dynamic> map) {
    final restored = LoyaltyTierRules(
      silverMinimumSpend: (map['silverMinimumSpend'] as num?)?.toDouble() ??
          defaults.silverMinimumSpend,
      goldMinimumSpend: (map['goldMinimumSpend'] as num?)?.toDouble() ??
          defaults.goldMinimumSpend,
      memberPointsMultiplier:
          (map['memberPointsMultiplier'] as num?)?.toDouble() ??
              defaults.memberPointsMultiplier,
      silverPointsMultiplier:
          (map['silverPointsMultiplier'] as num?)?.toDouble() ??
              defaults.silverPointsMultiplier,
      goldPointsMultiplier: (map['goldPointsMultiplier'] as num?)?.toDouble() ??
          defaults.goldPointsMultiplier,
    );

    return restored.isValid ? restored : defaults;
  }
}

class CustomerLoyaltyTierProfile {
  const CustomerLoyaltyTierProfile({
    required this.customerId,
    required this.lifetimeEligibleSpend,
    required this.tier,
    required this.pointsMultiplier,
  });

  final String customerId;
  final double lifetimeEligibleSpend;
  final LoyaltyTier tier;
  final double pointsMultiplier;

  int rewardPoints(int basePoints) {
    if (basePoints <= 0) return 0;
    return (basePoints * pointsMultiplier).floor();
  }
}
