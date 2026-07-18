import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'bdd-loyalty-receipt-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-loyalty-receipt-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
    await repository.login(
      email: 'owner@demo.local',
      password: 'owner123',
    );

    await repository.loyaltyRepository.earnForOrder(
      customerId: 'customer-1',
      orderId: 'receipt-balance-source',
      eligibleAmount: 50000,
    );
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'Given a customer redeems 3 points at checkout, '
    'When the persisted order becomes receipt data, '
    'Then the receipt shows used earned and final points',
    () async {
      // Given:
      final order = OrderModel(
        id: 'bdd-loyalty-receipt',
        orderId: 'BDD-LOYALTY-RECEIPT',
        items: [
          CartItemModel(
            id: 'water',
            name: 'Mineral Water',
            size: 'Regular',
            price: 20000,
            quantity: 2,
          ),
        ],
        subtotal: 40000,
        discount: 0,
        discountValue: 0,
        loyaltyPointsRedeemed: 3,
        loyaltyDiscount: 300,
        taxableAmount: 39700,
        taxType: TaxType.none,
        taxValue: 0,
        taxAmount: 0,
        totalAmount: 39700,
        paid: 40000,
        amountReceived: 40000,
        amountApplied: 39700,
        change: 300,
        createdAt: DateTime.now(),
        createdBy: 'bdd-owner',
        status: OrderStatus.draft,
        receiptStatus: ReceiptState.pending,
        customerId: 'customer-1',
        customerName: 'Budi Santoso',
      );

      // When:
      final result = await repository.completeSale(order);
      expect(result.isSuccess, isTrue);

      final receipt = ReceiptData.fromOrder(result.value!);

      // Then:
      expect(receipt.customerName, 'Budi Santoso');
      expect(receipt.loyaltyPointsRedeemed, 3);
      expect(receipt.loyaltyDiscount, 300);
      expect(receipt.loyaltyPointsEarned, 3);
      expect(receipt.loyaltyBalanceAfter, 5);
      expect(receipt.total, 39700);
      expect(receipt.change, 300);
    },
  );
}
