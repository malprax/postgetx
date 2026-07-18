import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/repositories/pos_operation_result.dart';

abstract class LoyaltyRepository {
  Future<List<LoyaltyLedgerEntry>> getLedger({
    String? customerId,
  });

  Future<int> getBalance(String customerId);

  Future<CustomerLoyaltyTierProfile> getTierProfile(
    String customerId,
  );

  Future<PosOperationResult<LoyaltyLedgerEntry>> earnForOrder({
    required String customerId,
    required String orderId,
    required double eligibleAmount,
  });

  Future<PosOperationResult<LoyaltyLedgerEntry>> redeem({
    required String customerId,
    required int points,
    required String reason,
  });

  Future<PosOperationResult<LoyaltyLedgerEntry>> redeemForOrder({
    required String customerId,
    required String orderId,
    required int points,
    required String reason,
  });

  Future<PosOperationResult<LoyaltyLedgerEntry>> restoreOrderRedemption({
    required String orderId,
    required String reason,
  });

  Future<PosOperationResult<LoyaltyLedgerEntry>> reverseOrderEarning({
    required String orderId,
    required String reason,
  });
}
