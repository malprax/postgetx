import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/core/config/app_config.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/customer_model.dart';
import 'package:postgetx/models/expense_model.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'retail-pos-test',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'demo-${DateTime.now().microsecondsSinceEpoch}',
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

  test('demo login and seed data are available', () async {
    final user = await repository.login(
      email: AppConfig.demoEmail,
      password: AppConfig.demoPassword,
    );

    expect(user.role, 'owner');
    expect(await repository.getCategories(), isNotEmpty);
    expect(await repository.getProducts(), isNotEmpty);
    expect(await repository.getCustomers(), isNotEmpty);
    expect(await repository.getTransactions(), isNotEmpty);
  });

  test('transaction persists and reset restores original data', () async {
    final before = await repository.getTransactions();

    final items = [
      CartItemModel(
        id: 'cola',
        name: 'Cola',
        size: 'Regular',
        price: 12500,
        quantity: 1,
      ),
    ];

    final totals = const PosTotalCalculator().calculate(
      items: items,
      discountType: DiscountType.fixed,
      discountValue: 0,
      amountPaid: 15000,
    );

    final transaction = OrderModel(
      id: 'test-sale',
      orderId: 'TEST-SALE',
      items: items,
      subtotal: totals.subtotal,
      discountType: totals.discountType,
      discountValue: totals.discountValue,
      discount: totals.discountAmount,
      taxableAmount: totals.taxableAmount,
      tax: totals.tax,
      totalAmount: totals.total,
      paid: totals.amountPaid,
      change: totals.change,
      createdAt: DateTime.now(),
      createdBy: AppConfig.demoEmail,
    );

    await repository.saveTransaction(transaction);

    expect(
      (await repository.getTransactions()).any(
        (order) => order.id == 'test-sale',
      ),
      isTrue,
    );

    await repository.resetDemoData();

    final reset = await repository.getTransactions();

    expect(reset.length, before.length);

    expect(
      reset.any(
        (order) => order.id == 'test-sale',
      ),
      isFalse,
    );
  });

  test('local CRUD covers stock customers expenses and orders', () async {
    final product = (await repository.getProducts()).first;

    await repository.updateProduct(
      product.copyWith(stock: 99),
    );

    expect(
      (await repository.getProducts())
          .firstWhere(
            (item) => item.id == product.id,
          )
          .stock,
      99,
    );

    final customer = CustomerModel(
      id: 'crud-customer',
      membershipId: '',
      email: 'crud@local.test',
      name: 'CRUD Customer',
      phone: '081234567891',
      normalizedPhone: '',
      whatsapp: '081234567891',
      normalizedWhatsapp: '',
      createdAt: DateTime.now(),
    );

    final createdCustomer = await repository.createCustomer(
      customer,
    );

    expect(
      createdCustomer.phone,
      '081234567891',
    );

    expect(
      createdCustomer.normalizedPhone,
      '6281234567891',
    );

    expect(
      createdCustomer.whatsapp,
      '081234567891',
    );

    expect(
      createdCustomer.normalizedWhatsapp,
      '6281234567891',
    );

    expect(
      (await repository.getCustomers()).any(
        (item) => item.id == createdCustomer.id,
      ),
      isTrue,
    );

    final foundByPhone = await repository.findCustomerByPhone(
      '081234567891',
    );

    expect(foundByPhone?.id, createdCustomer.id);

    final searchByWhatsapp = await repository.searchCustomers(
      '081234567891',
    );

    expect(
      searchByWhatsapp.any(
        (item) => item.id == createdCustomer.id,
      ),
      isTrue,
    );

    final deletion = await repository.deleteCustomer(
      createdCustomer.id,
    );

    expect(deletion.isSuccess, isTrue);

    expect(
      deletion.value?.whatsapp,
      '081234567891',
    );

    expect(
      deletion.value?.normalizedWhatsapp,
      '6281234567891',
    );

    expect(
      (await repository.getCustomers()).any(
        (item) => item.id == createdCustomer.id,
      ),
      isFalse,
    );

    expect(
      (await repository.getCustomers(includeDeleted: true)).any(
        (item) =>
            item.id == createdCustomer.id &&
            item.isDeleted &&
            item.whatsapp == '081234567891' &&
            item.normalizedWhatsapp == '6281234567891',
      ),
      isTrue,
    );

    final restoration = await repository.restoreCustomer(
      createdCustomer.id,
    );

    expect(restoration.isSuccess, isTrue);

    expect(
      restoration.value?.whatsapp,
      '081234567891',
    );

    expect(
      restoration.value?.normalizedWhatsapp,
      '6281234567891',
    );

    expect(
      (await repository.getCustomers()).any(
        (item) =>
            item.id == createdCustomer.id &&
            !item.isDeleted &&
            item.whatsapp == '081234567891',
      ),
      isTrue,
    );

    final expense = ExpenseModel(
      id: 'crud-expense',
      title: 'Local expense',
      amount: 50000,
      category: 'Test',
      createdAt: DateTime.now(),
    );

    await repository.saveExpense(expense);

    expect(
      (await repository.getExpenses()).any(
        (item) => item.id == expense.id,
      ),
      isTrue,
    );

    await repository.deleteExpense(expense.id);

    expect(
      (await repository.getExpenses()).any(
        (item) => item.id == expense.id,
      ),
      isFalse,
    );

    final order = (await repository.getTransactions()).first;

    final orderDeletion = await repository.deleteOpenOrder(
      order.id,
    );

    expect(orderDeletion.isSuccess, isFalse);

    expect(
      (await repository.getTransactions()).any(
        (item) => item.id == order.id,
      ),
      isTrue,
    );
  });
}
