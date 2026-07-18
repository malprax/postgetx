import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
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
      'postgetx-bdd-loyalty-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'bdd-loyalty-${DateTime.now().microsecondsSinceEpoch}',
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

  OrderModel customerSale(String id, {double total = 40000}) {
    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
          id: 'water',
          name: 'Mineral Water',
          size: 'Regular',
          price: total / 2,
          quantity: 2,
        ),
      ],
      totalAmount: total,
      discount: 0,
      tax: 0,
      paid: total,
      change: 0,
      createdAt: DateTime.now(),
      createdBy: 'bdd-owner',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
      customerId: 'customer-1',
      customerName: 'Budi Santoso',
    );
  }

  group('Feature: Customer earns loyalty points', () {
    test(
      'Given a registered customer, '
      'When a Rp40.000 sale completes, '
      'Then the customer earns 4 points exactly once',
      () async {
        // Given:
        final order = customerSale('bdd-earned-points');

        // When:
        final completed = await repository.completeSale(order);
        final duplicate = await repository.completeSale(order);

        // Then:
        expect(completed.isSuccess, isTrue);
        expect(duplicate.isSuccess, isFalse);
        expect(duplicate.code, 'already_completed');

        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          4,
        );

        final ledger = await repository.loyaltyRepository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) => entry.type == LoyaltyEntryType.earned,
          ),
          hasLength(1),
        );
      },
    );
  });

  group('Feature: Refund reverses loyalty points', () {
    test(
      'Given a completed customer sale, '
      'When the sale is refunded, '
      'Then earned points are reversed exactly once',
      () async {
        // Given:
        final order = customerSale('bdd-refund-points');
        final completed = await repository.completeSale(order);
        expect(completed.isSuccess, isTrue);
        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          4,
        );

        // When:
        final refunded = await repository.refundSale(
          order.id,
          'BDD customer return',
        );

        final duplicate = await repository.refundSale(
          order.id,
          'BDD duplicate refund',
        );

        // Then:
        expect(refunded.isSuccess, isTrue);
        expect(duplicate.isSuccess, isFalse);
        expect(duplicate.code, 'already_refunded');

        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          0,
        );

        final ledger = await repository.loyaltyRepository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) => entry.type == LoyaltyEntryType.reversed,
          ),
          hasLength(1),
        );
      },
    );
  });

  group('Feature: Customer redeems available points', () {
    test(
      'Given a customer has 5 points, '
      'When 3 points are redeemed, '
      'Then the balance becomes 2 and an audit entry is recorded',
      () async {
        // Given:
        await repository.loyaltyRepository.earnForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-redeem-source',
          eligibleAmount: 50000,
        );

        // When:
        final result = await repository.loyaltyRepository.redeem(
          customerId: 'customer-1',
          points: 3,
          reason: 'BDD member reward',
        );

        // Then:
        expect(result.isSuccess, isTrue);
        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          2,
        );

        expect(result.value?.type, LoyaltyEntryType.redeemed);
        expect(result.value?.pointsDelta, -3);
        expect(result.value?.reason, 'BDD member reward');
        expect(result.value?.actorId, 'demo-owner');
      },
    );
  });

  group('Feature: Loyalty balance is protected', () {
    test(
      'Given a customer has 2 points, '
      'When 3 points are requested, '
      'Then redemption is rejected and the balance remains unchanged',
      () async {
        // Given:
        await repository.loyaltyRepository.earnForOrder(
          customerId: 'customer-1',
          orderId: 'bdd-protected-balance',
          eligibleAmount: 20000,
        );

        // When:
        final result = await repository.loyaltyRepository.redeem(
          customerId: 'customer-1',
          points: 3,
          reason: 'BDD excessive redemption',
        );

        // Then:
        expect(result.isSuccess, isFalse);
        expect(result.code, 'insufficient_loyalty_points');

        expect(
          await repository.loyaltyRepository.getBalance('customer-1'),
          2,
        );

        final ledger = await repository.loyaltyRepository.getLedger(
          customerId: 'customer-1',
        );

        expect(
          ledger.where(
            (entry) => entry.type == LoyaltyEntryType.redeemed,
          ),
          isEmpty,
        );
      },
    );
  });
}
