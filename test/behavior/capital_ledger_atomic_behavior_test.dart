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
      'capital-ledger-test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'capital-${DateTime.now().microsecondsSinceEpoch}',
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
    const discount = 1500.0;
    const tax = 1350.0;
    const total = 14850.0;

    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
          id: 'water',
          name: 'Water Bottle 500ml',
          size: 'Regular',
          price: 7500,
          costPrice: 1,
          quantity: 2,
        ),
      ],
      totalAmount: total,
      discount: discount,
      tax: tax,
      paid: total,
      change: 0,
      createdAt: DateTime.now(),
      createdBy: 'test',
      status: OrderStatus.draft,
      receiptStatus: ReceiptState.pending,
    );
  }

  test(
    'Given a completed sale, When capital is allocated, '
    'Then trusted restock cost and gross margin are stored',
    () async {
      final result = await repository.completeSale(
        sale('capital-sale'),
      );

      expect(result.isSuccess, isTrue);

      final ledger = await repository.getCapitalLedger();
      final entry = ledger.singleWhere(
        (item) => item.orderId == 'capital-sale',
      );

      expect(entry.type, CapitalLedgerEntryType.saleAllocation);
      expect(entry.salesRevenueDelta, 13500);
      expect(entry.restockRequirementDelta, 9000);
      expect(entry.grossMarginDelta, 4500);
    },
  );

  test(
    'Given a sale has a capital allocation, When it is refunded, '
    'Then an exact capital reversal is stored',
    () async {
      expect(
        (await repository.completeSale(
          sale('capital-refund'),
        ))
            .isSuccess,
        isTrue,
      );

      expect(
        (await repository.refundSale(
          'capital-refund',
          'Customer returned goods',
        ))
            .isSuccess,
        isTrue,
      );

      final ledger = (await repository.getCapitalLedger())
          .where((entry) => entry.orderId == 'capital-refund')
          .toList();

      expect(ledger, hasLength(2));

      final allocation = ledger.firstWhere(
        (entry) => entry.type == CapitalLedgerEntryType.saleAllocation,
      );
      final reversal = ledger.firstWhere(
        (entry) => entry.type == CapitalLedgerEntryType.refundReversal,
      );

      expect(
        reversal.salesRevenueDelta,
        -allocation.salesRevenueDelta,
      );
      expect(
        reversal.restockRequirementDelta,
        -allocation.restockRequirementDelta,
      );
      expect(
        reversal.grossMarginDelta,
        -allocation.grossMarginDelta,
      );
      expect(reversal.reversesEntryId, allocation.id);
    },
  );

  test(
    'Given capital ledger persistence fails, When checkout runs, '
    'Then product order and capital ledger all roll back',
    () async {
      final failing = LocalHiveRepository.forBox(
        box,
        writeFaultInjector: (stage) {
          if (stage == 'after_capital_ledger') {
            throw StateError('injected capital failure');
          }
        },
      );
      await failing.restoreSession();

      final stockBefore = (await failing.getProducts())
          .firstWhere(
            (product) => product.id == 'water',
          )
          .stock;
      final ordersBefore = (await failing.getTransactions()).length;
      final ledgerBefore = (await failing.getCapitalLedger()).length;

      final result = await failing.completeSale(
        sale('capital-rollback'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.code, 'atomic_write_failed');
      expect(
        (await failing.getProducts())
            .firstWhere(
              (product) => product.id == 'water',
            )
            .stock,
        stockBefore,
      );
      expect(
        (await failing.getTransactions()).length,
        ordersBefore,
      );
      expect(
        (await failing.getCapitalLedger()).length,
        ledgerBefore,
      );
    },
  );
}
