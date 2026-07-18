import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/loyalty_ledger_entry.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'bdd-atomic-loyalty-checkout-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-atomic-loyalty-${DateTime.now().microsecondsSinceEpoch}',
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

  Future<void> giveCustomerPoints(int points) {
    return repository.loyaltyRepository
        .earnForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-balance-source-$points',
          eligibleAmount: points * 10000,
        )
        .then((_) {});
  }

  OrderModel loyaltySale(
    String id, {
    int points = 3,
  }) {
    final loyaltyDiscount = points * 100;
    final total = 40000 - loyaltyDiscount;

    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
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
      loyaltyPointsRedeemed: points,
      loyaltyDiscount: loyaltyDiscount.toDouble(),
      taxableAmount: total.toDouble(),
      taxType: TaxType.none,
      taxValue: 0,
      taxAmount: 0,
      totalAmount: total.toDouble(),
      paid: 40000,
      amountReceived: 40000,
      amountApplied: total.toDouble(),
      change: loyaltyDiscount.toDouble(),
      createdAt: DateTime.now(),
      createdBy: 'bdd-owner',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
      customerId: 'customer-1',
      customerName: 'Budi Santoso',
    );
  }

  group('Feature: Loyalty checkout is atomic', () {
    test(
      'Given a customer has 5 points, '
      'When checkout redeems 3 points successfully, '
      'Then redemption and earning share the completed order',
      () async {
        // Given:
        await giveCustomerPoints(5);

        // When:
        final result = await repository.completeSale(
          loyaltySale('bdd-atomic-sale'),
        );

        // Then:
        expect(result.isSuccess, isTrue);
        expect(result.value?.loyaltyPointsRedeemed, 3);
        expect(result.value?.loyaltyDiscount, 300);

        final ledger = await repository.loyaltyRepository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) =>
                entry.orderId == 'bdd-atomic-sale' &&
                entry.type == LoyaltyEntryType.redeemed,
          ),
          hasLength(1),
        );

        expect(
          ledger.where(
            (entry) =>
                entry.orderId == 'bdd-atomic-sale' &&
                entry.type == LoyaltyEntryType.earned,
          ),
          hasLength(1),
        );

        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          5,
        );
      },
    );

    test(
      'Given a customer has only 2 points, '
      'When checkout requests 3 points, '
      'Then stock order and ledger remain unchanged',
      () async {
        // Given:
        await giveCustomerPoints(2);

        final stockBefore = (await repository.getProducts())
            .firstWhere((product) => product.id == 'water')
            .stock;

        final ordersBefore = (await repository.getTransactions()).length;

        final ledgerBefore = (await repository.loyaltyRepository.getLedger())
            .map((entry) => entry.toMap())
            .toList();

        // When:
        final result = await repository.completeSale(
          loyaltySale('bdd-insufficient-points'),
        );

        // Then:
        expect(result.isSuccess, isFalse);
        expect(result.code, 'insufficient_loyalty_points');

        expect(
          (await repository.getProducts())
              .firstWhere((product) => product.id == 'water')
              .stock,
          stockBefore,
        );

        expect(
          (await repository.getTransactions()).length,
          ordersBefore,
        );

        expect(
          (await repository.loyaltyRepository.getLedger())
              .map((entry) => entry.toMap())
              .toList(),
          ledgerBefore,
        );
      },
    );

    test(
      'Given a completed order redeemed points, '
      'When the order is refunded, '
      'Then earned points reverse and redeemed points restore',
      () async {
        // Given:
        await giveCustomerPoints(5);

        final completed = await repository.completeSale(
          loyaltySale('bdd-refund-loyalty-sale'),
        );

        expect(completed.isSuccess, isTrue);

        // When:
        final refunded = await repository.refundSale(
          'bdd-refund-loyalty-sale',
          'BDD refund',
        );

        // Then:
        expect(refunded.isSuccess, isTrue);

        final ledger = await repository.loyaltyRepository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) =>
                entry.orderId == 'bdd-refund-loyalty-sale' &&
                entry.type == LoyaltyEntryType.reversed,
          ),
          hasLength(1),
        );

        expect(
          ledger.where(
            (entry) =>
                entry.orderId == 'bdd-refund-loyalty-sale' &&
                entry.type == LoyaltyEntryType.restored,
          ),
          hasLength(1),
        );

        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          5,
        );
      },
    );
  });
}
