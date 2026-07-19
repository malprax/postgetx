import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'owner-withdrawal-test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'withdrawal-${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  OrderModel sale(String id) {
    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
          id: 'water',
          name: 'Water Bottle 500ml',
          size: 'Regular',
          price: 7500,
          quantity: 2,
        ),
      ],
      totalAmount: 14850,
      discount: 1500,
      tax: 1350,
      paid: 14850,
      change: 0,
      createdAt: DateTime.now(),
      createdBy: 'test',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
    );
  }

  test(
    'Given available safe profit, When the owner withdraws within it, '
    'Then no protected capital is consumed',
    () async {
      expect(
        (await repository.completeSale(sale('safe-withdrawal-sale'))).isSuccess,
        isTrue,
      );

      final ordersBefore = await repository.getTransactions();

      final result = await repository.recordOwnerWithdrawal(
        amount: 1000,
        reason: 'Owner household allowance',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.withdrawalAmount, 1000);
      expect(result.value!.protectedCapitalImpact, 0);
      expect(result.value!.usesProtectedCapital, isFalse);
      expect(
        (await repository.getTransactions()).length,
        ordersBefore.length,
      );
    },
  );

  test(
    'Given a withdrawal exceeds safe profit, When it is recorded, '
    'Then the protected capital impact is visible',
    () async {
      expect(
        (await repository.completeSale(sale('risky-withdrawal-sale')))
            .isSuccess,
        isTrue,
      );

      final result = await repository.recordOwnerWithdrawal(
        amount: 5000,
        reason: 'Emergency personal consumption',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.usesProtectedCapital, isTrue);
      expect(result.value!.protectedCapitalImpact, 1400);

      final stored = (await repository.getCapitalLedger()).lastWhere(
        (entry) => entry.type == CapitalLedgerEntryType.ownerWithdrawal,
      );

      expect(stored.withdrawalAmount, 5000);
      expect(stored.protectedCapitalImpact, 1400);
    },
  );

  test(
    'Given a staff account, When an owner withdrawal is attempted, '
    'Then permission is denied and the ledger stays unchanged',
    () async {
      await repository.login(
        email: 'staff@demo.local',
        password: 'staff123',
      );

      final before = (await repository.getCapitalLedger()).length;

      final result = await repository.recordOwnerWithdrawal(
        amount: 1000,
        reason: 'Unauthorized attempt',
      );

      expect(result.isSuccess, isFalse);
      expect(result.code, 'permission_denied');
      expect(
        (await repository.getCapitalLedger()).length,
        before,
      );
    },
  );

  test(
    'Given invalid withdrawal details, When saving is attempted, '
    'Then no ledger entry is created',
    () async {
      final amountResult = await repository.recordOwnerWithdrawal(
        amount: 0,
        reason: 'Invalid amount',
      );
      final reasonResult = await repository.recordOwnerWithdrawal(
        amount: 1000,
        reason: ' ',
      );

      expect(amountResult.code, 'invalid_withdrawal_amount');
      expect(reasonResult.code, 'withdrawal_reason_required');
      expect(
        (await repository.getCapitalLedger())
            .where((entry) => entry.isOwnerWithdrawal),
        isEmpty,
      );
    },
  );
}
