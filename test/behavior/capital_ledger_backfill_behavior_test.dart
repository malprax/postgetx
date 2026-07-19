import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/capital_ledger_entry.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'capital-backfill-test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'backfill-${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = LocalHiveRepository.forBox(box);
    await repository.resetDemoData();
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'Given completed legacy demo sales have no capital ledger, '
    'When schema migration runs repeatedly, '
    'Then allocations are backfilled exactly once',
    () async {
      await box.delete(CapitalLedgerEntry.storageKey);
      await box.put('seedVersion', 8);

      await repository.migrateSchema();
      final first = await repository.getCapitalLedger();

      await repository.migrateSchema();
      final second = await repository.getCapitalLedger();

      final completedOrders = (await repository.getTransactions())
          .where(
            (order) =>
                order.status == OrderStatus.completed && order.stockApplied,
          )
          .toList();

      final allocations = first
          .where(
            (entry) => entry.type == CapitalLedgerEntryType.saleAllocation,
          )
          .toList();

      expect(allocations, hasLength(completedOrders.length));
      expect(
        allocations.map((entry) => entry.orderId).toSet(),
        completedOrders.map((order) => order.id).toSet(),
      );
      expect(second.length, first.length);
      expect(
        second.map((entry) => entry.id).toSet(),
        first.map((entry) => entry.id).toSet(),
      );
      expect(
        box.get('seedVersion'),
        LocalHiveRepository.currentSchemaVersion,
      );
    },
  );

  test(
    'Given a legacy refunded order, '
    'When capital data is backfilled, '
    'Then its allocation and exact reversal are both restored',
    () async {
      final transactions = (box.get('transactions') as List)
          .map(
            (value) => Map<String, dynamic>.from(
              value as Map,
            ),
          )
          .toList();

      final index = transactions.indexWhere(
        (map) => map['id'] == 'seed-1',
      );

      transactions[index] = {
        ...transactions[index],
        'status': OrderStatus.refunded,
        'stockApplied': true,
        'stockRestored': true,
        'refundedAt': DateTime(2026, 7, 19).toIso8601String(),
        'refundReason': 'Legacy customer refund',
        'refundedBy': 'demo-owner',
      };

      await box.put('transactions', transactions);
      await box.delete(CapitalLedgerEntry.storageKey);
      await box.put('seedVersion', 8);

      await repository.migrateSchema();

      final entries = (await repository.getCapitalLedger())
          .where((entry) => entry.orderId == 'seed-1')
          .toList();

      expect(entries, hasLength(2));

      final allocation = entries.firstWhere(
        (entry) => entry.type == CapitalLedgerEntryType.saleAllocation,
      );
      final reversal = entries.firstWhere(
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
    'Given open and cancelled orders, '
    'When capital data is backfilled, '
    'Then they never become protected capital',
    () async {
      final ledger = await repository.getCapitalLedger();
      final orderIds = ledger.map((entry) => entry.orderId).toSet();

      expect(orderIds, isNot(contains('seed-held')));
      expect(orderIds, isNot(contains('seed-saved')));
      expect(orderIds, isNot(contains('seed-4')));
      expect(orderIds, isNot(contains('seed-trash')));
    },
  );
}
