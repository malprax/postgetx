import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/config/app_config.dart';
import 'package:postgetx/models/customer_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> box;
  late LocalHiveRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'postgetx-customer-test-',
    );

    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'customer-${DateTime.now().microsecondsSinceEpoch}',
    );

    repository = LocalHiveRepository.forBox(box);

    await repository.resetDemoData();

    await repository.login(
      email: AppConfig.demoEmail,
      password: AppConfig.demoPassword,
    );
  });

  tearDown(() async {
    if (box.isOpen) {
      await box.close();
    }

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  CustomerModel createInput({
    String id = '',
    String membershipId = '',
    String name = 'Budi Santoso',
    String whatsapp = '081234567890',
    String phone = '081311112222',
    String email = 'budi@example.com',
  }) {
    return CustomerModel(
      id: id,
      membershipId: membershipId,
      name: name,
      whatsapp: whatsapp,
      normalizedWhatsapp: '',
      phone: phone,
      normalizedPhone: '',
      email: email,
      address: 'Makassar',
      notes: 'Pelanggan grosir',
      createdAt: DateTime.now(),
    );
  }

  test('creates and normalizes customer data', () async {
    final created = await repository.createCustomer(
      createInput(
        name: '  Budi Santoso  ',
        whatsapp: ' 0812-3456-7890 ',
        phone: ' 0813-1111-2222 ',
        email: ' budi@example.com ',
      ),
    );

    expect(created.id, isNotEmpty);
    expect(created.membershipId, isNotEmpty);
    expect(created.name, 'Budi Santoso');
    expect(created.whatsapp, '0812-3456-7890');
    expect(created.normalizedWhatsapp, '6281234567890');
    expect(created.phone, '0813-1111-2222');
    expect(created.normalizedPhone, '6281311112222');
    expect(created.email, 'budi@example.com');
    expect(created.createdAt, isNotNull);
    expect(created.updatedAt, isNotNull);

    final stored = await repository.getCustomerById(created.id);

    expect(stored?.id, created.id);
  });

  test('rejects duplicate WhatsApp in another format', () async {
    await repository.createCustomer(
      createInput(
        whatsapp: '081234567890',
        phone: '081311112222',
      ),
    );

    expect(
      () => repository.createCustomer(
        createInput(
          name: 'Duplicate Customer',
          whatsapp: '+6281234567890',
          phone: '081399999999',
          email: 'duplicate@example.com',
        ),
      ),
      throwsA(anything),
    );
  });

  test('searches customer by name and membership id', () async {
    final created = await repository.createCustomer(createInput());

    final byName = await repository.searchCustomers('budi');

    final byMembership = await repository.searchCustomers(
      created.membershipId,
    );

    expect(
      byName.map((item) => item.id),
      contains(created.id),
    );

    expect(
      byMembership.map((item) => item.id),
      contains(created.id),
    );
  });

  test('searches customer by WhatsApp and alternate phone', () async {
    final created = await repository.createCustomer(createInput());

    final byWhatsapp = await repository.searchCustomers(
      '+6281234567890',
    );

    final byPhone = await repository.searchCustomers(
      '081311112222',
    );

    expect(
      byWhatsapp.map((item) => item.id),
      contains(created.id),
    );

    expect(
      byPhone.map((item) => item.id),
      contains(created.id),
    );
  });

  test('finds customer by phone number', () async {
    final created = await repository.createCustomer(createInput());

    final found = await repository.findCustomerByPhone(
      '081234567890',
    );

    expect(found?.id, created.id);
  });

  test('updates customer and preserves identity fields', () async {
    final created = await repository.createCustomer(createInput());

    final originalCreatedAt = created.createdAt;

    await Future<void>.delayed(
      const Duration(milliseconds: 2),
    );

    final updated = await repository.updateCustomer(
      created.copyWith(
        name: 'Budi Updated',
        whatsapp: '081299999999',
        normalizedWhatsapp: '',
        phone: '081388888888',
        normalizedPhone: '',
      ),
    );

    expect(updated.id, created.id);
    expect(updated.membershipId, created.membershipId);
    expect(updated.createdAt, originalCreatedAt);
    expect(updated.name, 'Budi Updated');
    expect(updated.normalizedWhatsapp, '6281299999999');
    expect(updated.normalizedPhone, '6281388888888');
    expect(
      updated.updatedAt.isBefore(created.updatedAt),
      isFalse,
    );
  });

  test('soft deletes customer and preserves contact data', () async {
    final created = await repository.createCustomer(createInput());

    final result = await repository.deleteCustomer(created.id);

    expect(result.isSuccess, isTrue);
    expect(result.value?.isDeleted, isTrue);
    expect(result.value?.whatsapp, created.whatsapp);
    expect(
      result.value?.normalizedWhatsapp,
      created.normalizedWhatsapp,
    );
    expect(result.value?.deletedAt, isNotNull);
    expect(result.value?.deletedBy, isNotEmpty);

    final activeCustomers = await repository.getCustomers();

    expect(
      activeCustomers.any((item) => item.id == created.id),
      isFalse,
    );

    final allCustomers = await repository.getCustomers(
      includeDeleted: true,
    );

    expect(
      allCustomers.any(
        (item) => item.id == created.id && item.isDeleted,
      ),
      isTrue,
    );
  });

  test('restores a deleted customer', () async {
    final created = await repository.createCustomer(createInput());

    await repository.deleteCustomer(created.id);

    final result = await repository.restoreCustomer(created.id);

    expect(result.isSuccess, isTrue);
    expect(result.value?.isDeleted, isFalse);
    expect(result.value?.deletedAt, isNull);
    expect(result.value?.deletedBy, isEmpty);
    expect(result.value?.restoredAt, isNotNull);
    expect(result.value?.restoredBy, isNotEmpty);
    expect(result.value?.whatsapp, created.whatsapp);
    expect(
      result.value?.normalizedWhatsapp,
      created.normalizedWhatsapp,
    );

    final activeCustomers = await repository.getCustomers();

    expect(
      activeCustomers.any((item) => item.id == created.id),
      isTrue,
    );
  });

  test('returns failure when deleting unknown customer', () async {
    final before = await repository.getCustomers(
      includeDeleted: true,
    );

    final result = await repository.deleteCustomer(
      'missing-customer',
    );

    final after = await repository.getCustomers(
      includeDeleted: true,
    );

    expect(result.isSuccess, isFalse);
    expect(after.length, before.length);
  });

  test('returns failure when restoring unknown customer', () async {
    final before = await repository.getCustomers(
      includeDeleted: true,
    );

    final result = await repository.restoreCustomer(
      'missing-customer',
    );

    final after = await repository.getCustomers(
      includeDeleted: true,
    );

    expect(result.isSuccess, isFalse);
    expect(after.length, before.length);
  });

  test('reset restores demo customer data', () async {
    final original = await repository.getCustomers(
      includeDeleted: true,
    );

    final created = await repository.createCustomer(createInput());

    expect(
      (await repository.getCustomers()).any(
        (item) => item.id == created.id,
      ),
      isTrue,
    );

    await repository.resetDemoData();

    final reset = await repository.getCustomers(
      includeDeleted: true,
    );

    expect(reset.length, original.length);
    expect(
      reset.any((item) => item.id == created.id),
      isFalse,
    );
  });
}
