import 'package:postgetx/app/core/services/loyalty_points_policy.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/loyalty_repository.dart';
import 'package:postgetx/app/data/repositories/pos_operation_result.dart';

class LocalLoyaltyRepository implements LoyaltyRepository {
  LocalLoyaltyRepository(
    this._provider, {
    required String Function() actorId,
    LoyaltyConfiguration Function()? configuration,
    double Function(String customerId)? lifetimeEligibleSpend,
    LoyaltyTierRules Function()? tierRules,
  })  : _actorId = actorId,
        _configuration = configuration ?? (() => LoyaltyConfiguration.defaults),
        _lifetimeEligibleSpend = lifetimeEligibleSpend ?? ((_) => 0),
        _tierRules = tierRules ?? (() => LoyaltyTierRules.defaults);

  final HiveLoyaltyProvider _provider;
  final String Function() _actorId;
  final LoyaltyConfiguration Function() _configuration;
  final double Function(String customerId) _lifetimeEligibleSpend;
  final LoyaltyTierRules Function() _tierRules;

  @override
  Future<List<LoyaltyLedgerEntry>> getLedger({
    String? customerId,
  }) async {
    final entries = _provider
        .readEntries()
        .where(
          (entry) => customerId == null || entry.customerId == customerId,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return entries;
  }

  @override
  Future<int> getBalance(String customerId) async {
    final entries = await getLedger(customerId: customerId);
    return LoyaltyPointsPolicy.balance(
      entries.map((entry) => entry.pointsDelta),
    );
  }

  @override
  Future<CustomerLoyaltyTierProfile> getTierProfile(
    String customerId,
  ) async {
    final normalizedCustomerId = customerId.trim();

    final spending = normalizedCustomerId.isEmpty
        ? 0.0
        : _lifetimeEligibleSpend(normalizedCustomerId);

    final safeSpending = spending.isFinite && spending > 0 ? spending : 0.0;

    final configuredRules = _tierRules();

    final rules =
        configuredRules.isValid ? configuredRules : LoyaltyTierRules.defaults;

    final tier = rules.resolve(safeSpending);

    return CustomerLoyaltyTierProfile(
      customerId: normalizedCustomerId,
      lifetimeEligibleSpend: safeSpending,
      tier: tier,
      pointsMultiplier: rules.multiplierFor(tier),
    );
  }

  @override
  Future<PosOperationResult<LoyaltyLedgerEntry>> earnForOrder({
    required String customerId,
    required String orderId,
    required double eligibleAmount,
  }) async {
    if (customerId.trim().isEmpty || orderId.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_reference_required',
        'Customer and order references are required.',
      );
    }

    final entries = _provider.readEntries();
    final existing = entries
        .where(
          (entry) =>
              entry.orderId == orderId && entry.type == LoyaltyEntryType.earned,
        )
        .firstOrNull;

    if (existing != null) {
      return PosOperationResult.success(
        existing,
        isIdempotent: true,
      );
    }

    final configuration = _configuration();

    final basePoints = LoyaltyPointsPolicy.earnedPoints(
      eligibleAmount,
      isEnabled: configuration.isEnabled,
      spendingRequired: configuration.spendPerPoint,
      minimumEligibleTransaction: configuration.minimumEligibleTransaction,
    );

    final tierProfile = await getTierProfile(customerId);

    final points = tierProfile.rewardPoints(basePoints);

    if (points <= 0) {
      return PosOperationResult.failure(
        'no_loyalty_points',
        'This transaction does not earn loyalty points.',
      );
    }

    final now = DateTime.now();
    final entry = LoyaltyLedgerEntry(
      id: 'loyalty-${now.microsecondsSinceEpoch}',
      customerId: customerId.trim(),
      type: LoyaltyEntryType.earned,
      pointsDelta: points,
      createdAt: now,
      actorId: _actorId(),
      orderId: orderId.trim(),
      reason: 'Completed sale',
    );

    await _provider.writeEntries([...entries, entry]);
    return PosOperationResult.success(entry);
  }

  @override
  Future<PosOperationResult<LoyaltyLedgerEntry>> redeem({
    required String customerId,
    required int points,
    required String reason,
  }) async {
    if (points <= 0) {
      return PosOperationResult.failure(
        'invalid_loyalty_points',
        'Redeemed points must be greater than zero.',
      );
    }

    if (reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_reason_required',
        'A redemption reason is required.',
      );
    }

    final balance = await getBalance(customerId);
    if (balance < points) {
      return PosOperationResult.failure(
        'insufficient_loyalty_points',
        'The customer does not have enough loyalty points.',
      );
    }

    final now = DateTime.now();
    final entry = LoyaltyLedgerEntry(
      id: 'loyalty-${now.microsecondsSinceEpoch}',
      customerId: customerId.trim(),
      type: LoyaltyEntryType.redeemed,
      pointsDelta: -points,
      createdAt: now,
      actorId: _actorId(),
      reason: reason.trim(),
    );

    final entries = _provider.readEntries();
    await _provider.writeEntries([...entries, entry]);
    return PosOperationResult.success(entry);
  }

  @override
  Future<PosOperationResult<LoyaltyLedgerEntry>> redeemForOrder({
    required String customerId,
    required String orderId,
    required int points,
    required String reason,
  }) async {
    if (customerId.trim().isEmpty || orderId.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_reference_required',
        'Customer and order references are required.',
      );
    }

    if (points <= 0) {
      return PosOperationResult.failure(
        'invalid_loyalty_points',
        'Redeemed points must be greater than zero.',
      );
    }

    if (reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_reason_required',
        'A redemption reason is required.',
      );
    }

    final entries = _provider.readEntries();

    final existing = entries
        .where(
          (entry) =>
              entry.orderId == orderId &&
              entry.type == LoyaltyEntryType.redeemed,
        )
        .firstOrNull;

    if (existing != null) {
      return PosOperationResult.success(
        existing,
        isIdempotent: true,
      );
    }

    final balance = await getBalance(customerId);

    if (balance < points) {
      return PosOperationResult.failure(
        'insufficient_loyalty_points',
        'The customer does not have enough loyalty points.',
      );
    }

    final now = DateTime.now();

    final redemption = LoyaltyLedgerEntry(
      id: 'loyalty-${now.microsecondsSinceEpoch}',
      customerId: customerId.trim(),
      type: LoyaltyEntryType.redeemed,
      pointsDelta: -points,
      createdAt: now,
      actorId: _actorId(),
      orderId: orderId.trim(),
      reason: reason.trim(),
    );

    await _provider.writeEntries([
      ...entries,
      redemption,
    ]);

    return PosOperationResult.success(redemption);
  }

  @override
  Future<PosOperationResult<LoyaltyLedgerEntry>> restoreOrderRedemption({
    required String orderId,
    required String reason,
  }) async {
    if (orderId.trim().isEmpty || reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_restoration_reference_required',
        'Order and restoration reason are required.',
      );
    }

    final entries = _provider.readEntries();

    final existing = entries
        .where(
          (entry) =>
              entry.orderId == orderId &&
              entry.type == LoyaltyEntryType.restored,
        )
        .firstOrNull;

    if (existing != null) {
      return PosOperationResult.success(
        existing,
        isIdempotent: true,
      );
    }

    final redemption = entries
        .where(
          (entry) =>
              entry.orderId == orderId &&
              entry.type == LoyaltyEntryType.redeemed,
        )
        .firstOrNull;

    if (redemption == null) {
      return PosOperationResult.failure(
        'loyalty_redemption_missing',
        'No redeemed points were found for this order.',
      );
    }

    final now = DateTime.now();

    final restoration = LoyaltyLedgerEntry(
      id: 'loyalty-${now.microsecondsSinceEpoch}',
      customerId: redemption.customerId,
      type: LoyaltyEntryType.restored,
      pointsDelta: -redemption.pointsDelta,
      createdAt: now,
      actorId: _actorId(),
      orderId: orderId.trim(),
      reason: reason.trim(),
    );

    await _provider.writeEntries([
      ...entries,
      restoration,
    ]);

    return PosOperationResult.success(restoration);
  }

  @override
  Future<PosOperationResult<LoyaltyLedgerEntry>> reverseOrderEarning({
    required String orderId,
    required String reason,
  }) async {
    if (orderId.trim().isEmpty || reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'loyalty_reversal_reference_required',
        'Order and reversal reason are required.',
      );
    }

    final entries = _provider.readEntries();

    final existing = entries
        .where(
          (entry) =>
              entry.orderId == orderId &&
              entry.type == LoyaltyEntryType.reversed,
        )
        .firstOrNull;

    if (existing != null) {
      return PosOperationResult.success(
        existing,
        isIdempotent: true,
      );
    }

    final earned = entries
        .where(
          (entry) =>
              entry.orderId == orderId && entry.type == LoyaltyEntryType.earned,
        )
        .firstOrNull;

    if (earned == null) {
      return PosOperationResult.failure(
        'loyalty_earning_missing',
        'No earned points were found for this order.',
      );
    }

    final balance = await getBalance(earned.customerId);
    if (balance < earned.pointsDelta) {
      return PosOperationResult.failure(
        'insufficient_points_for_reversal',
        'Earned points have already been used.',
      );
    }

    final now = DateTime.now();
    final reversal = LoyaltyLedgerEntry(
      id: 'loyalty-${now.microsecondsSinceEpoch}',
      customerId: earned.customerId,
      type: LoyaltyEntryType.reversed,
      pointsDelta: -earned.pointsDelta,
      createdAt: now,
      actorId: _actorId(),
      orderId: orderId.trim(),
      reason: reason.trim(),
    );

    await _provider.writeEntries([...entries, reversal]);
    return PosOperationResult.success(reversal);
  }
}
