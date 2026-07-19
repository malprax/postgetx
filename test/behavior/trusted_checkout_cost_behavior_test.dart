import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      'trusted-checkout-cost-test',
    );
    Hive.init(directory.path);
    box = await Hive.openBox<dynamic>(
      'trusted-cost-${DateTime.now().microsecondsSinceEpoch}',
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

  OrderModel sale({
    required String id,
    double submittedCostPrice = 1,
  }) {
    const price = 7500.0;
    const quantity = 2;
    const subtotal = price * quantity;
    const discount = subtotal * .1;
    const tax = (subtotal - discount) * .1;
    const total = subtotal - discount + tax;

    return OrderModel(
      id: id,
      orderId: id.toUpperCase(),
      items: [
        CartItemModel(
          id: 'water',
          name: 'Water Bottle 500ml',
          size: 'Regular',
          price: price,
          costPrice: submittedCostPrice,
          quantity: quantity,
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
    'Given a cart submits a manipulated cost price, '
    'When checkout completes, '
    'Then the stored order uses the trusted product cost basis',
    () async {
      final result = await repository.completeSale(
        sale(
          id: 'trusted-cost-sale',
          submittedCostPrice: 1,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.items.single.costPrice, 4500);

      final stored = (await repository.getTransactions()).firstWhere(
        (order) => order.id == 'trusted-cost-sale',
      );

      expect(stored.items.single.costPrice, 4500);
      expect(stored.items.single.lineCost, 9000);
    },
  );

  test(
    'Given a product has no valid cost basis, '
    'When checkout is attempted, '
    'Then stock and orders remain unchanged',
    () async {
      final product = (await repository.getProducts()).firstWhere(
        (item) => item.id == 'water',
      );

      await repository.updateProduct(
        product.copyWith(
          variants: product.variants
              .map(
                (variant) => variant.copyWith(costPrice: 0),
              )
              .toList(),
        ),
      );

      final stockBefore = (await repository.getProducts())
          .firstWhere(
            (item) => item.id == 'water',
          )
          .stock;
      final ordersBefore = (await repository.getTransactions()).length;

      final result = await repository.completeSale(
        sale(id: 'missing-cost-sale'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.code, 'cost_basis_missing');
      expect(
        (await repository.getProducts())
            .firstWhere(
              (item) => item.id == 'water',
            )
            .stock,
        stockBefore,
      );
      expect(
        (await repository.getTransactions()).length,
        ordersBefore,
      );
    },
  );
}
