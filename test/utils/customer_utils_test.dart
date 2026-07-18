import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/models/customer_model.dart';
import 'package:postgetx/repositories/customer_repository.dart';
import 'package:postgetx/utils/customer_utils.dart';

void main() {
  late FakeCustomerRepository repository;

  setUp(() {
    repository = FakeCustomerRepository();
  });

  CustomerModel createInput({
    String id = '',
    String membershipId = '',
    String name = 'Budi Santoso',
    String whatsapp = '081234567890',
    String phone = '0411123456',
  }) {
    return CustomerModel(
      id: id,
      membershipId: membershipId,
      name: name,
      whatsapp: whatsapp,
      normalizedWhatsapp: '',
      phone: phone,
      normalizedPhone: '',
      email: 'budi@example.com',
      address: 'Makassar',
      notes: 'Pelanggan grosir',
      createdAt: DateTime(2026, 7, 18),
    );
  }

  test('creates and retrieves customer', () async {
    final created = await repository.createCustomer(createInput());

    final customers = await repository.getCustomers();
    final byId = await repository.getCustomerById(created.id);

    expect(customers, contains(created));
    expect(byId, created);
    expect(created.id, isNotEmpty);
    expect(created.membershipId, isNotEmpty);
  });

  test('updates customer', () async {
    final created = await repository.createCustomer(createInput());

    final updated = await repository.updateCustomer(
      created.copyWith(name: 'Budi Updated'),
    );

    expect(updated.name, 'Budi Updated');
    expect(
      (await repository.getCustomerById(created.id))?.name,
      'Budi Updated',
    );
  });

  test('searches by name and membership id', () async {
    final created = await repository.createCustomer(createInput());

    final byName = await repository.searchCustomers('budi');
    final byMembership = await repository.searchCustomers(
      created.membershipId,
    );

    expect(byName.map((item) => item.id), contains(created.id));
    expect(
      byMembership.map((item) => item.id),
      contains(created.id),
    );
  });

  test('searches by WhatsApp and alternate phone', () async {
    final created = await repository.createCustomer(createInput());

    final byWhatsapp = await repository.searchCustomers(
      '+6281234567890',
    );

    final byPhone = await repository.searchCustomers(
      '0411123456',
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

  test('finds customer by WhatsApp or alternate phone', () async {
    final created = await repository.createCustomer(createInput());

    final byWhatsapp = await repository.findCustomerByPhone(
      '081234567890',
    );

    final byPhone = await repository.findCustomerByPhone(
      '0411123456',
    );

    expect(byWhatsapp?.id, created.id);
    expect(byPhone?.id, created.id);
  });

  test('soft deletes and restores customer', () async {
    final created = await repository.createCustomer(createInput());

    final deletion = await repository.deleteCustomer(created.id);

    expect(deletion.isSuccess, isTrue);
    expect(deletion.value?.isDeleted, isTrue);
    expect(await repository.getCustomers(), isEmpty);
    expect(
      await repository.getCustomers(includeDeleted: true),
      hasLength(1),
    );

    final restoration = await repository.restoreCustomer(created.id);

    expect(restoration.isSuccess, isTrue);
    expect(restoration.value?.isDeleted, isFalse);
    expect(await repository.getCustomers(), hasLength(1));
  });

  test('returns failure when deleting an unknown customer', () async {
    final result = await repository.deleteCustomer('missing');

    expect(result.isSuccess, isFalse);
    expect(result.value, isNull);
    expect(result.message, isNotEmpty);
  });

  test('returns failure when restoring an unknown customer', () async {
    final result = await repository.restoreCustomer('missing');

    expect(result.isSuccess, isFalse);
    expect(result.value, isNull);
    expect(result.message, isNotEmpty);
  });

  test('CustomerMutationResult equality and hashCode are consistent', () {
    final customer = createInput(id: 'customer-1');

    final first = CustomerMutationResult.success(
      message: 'Success',
      value: customer,
    );

    final second = CustomerMutationResult.success(
      message: 'Success',
      value: customer,
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });
}

class FakeCustomerRepository implements CustomerRepository {
  final Map<String, CustomerModel> _customers = {};

  int _idSequence = 0;
  int _membershipSequence = 0;

  @override
  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    _idSequence++;
    _membershipSequence++;

    final normalized = customer.normalizeContactNumbers();

    final created = normalized.copyWith(
      id: normalized.id.isEmpty ? 'customer-$_idSequence' : normalized.id,
      membershipId: normalized.membershipId.isEmpty
          ? CustomerUtils.generateMembershipId(_membershipSequence)
          : normalized.membershipId,
      createdAt: normalized.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _customers[created.id] = created;

    return created;
  }

  @override
  Future<CustomerModel?> findCustomerByPhone(
    String phone, {
    bool includeDeleted = false,
  }) async {
    final normalized = CustomerUtils.normalizePhone(phone);

    for (final customer in _customers.values) {
      if (!includeDeleted && customer.isDeleted) {
        continue;
      }

      if (customer.normalizedWhatsapp == normalized ||
          customer.normalizedPhone == normalized) {
        return customer;
      }
    }

    return null;
  }

  @override
  Future<CustomerModel?> getCustomerById(
    String id, {
    bool includeDeleted = false,
  }) async {
    final customer = _customers[id];

    if (customer == null) {
      return null;
    }

    if (!includeDeleted && customer.isDeleted) {
      return null;
    }

    return customer;
  }

  @override
  Future<List<CustomerModel>> getCustomers({
    bool includeDeleted = false,
  }) async {
    return _customers.values.where((customer) {
      return includeDeleted || !customer.isDeleted;
    }).toList();
  }

  @override
  Future<List<CustomerModel>> searchCustomers(
    String query, {
    bool includeDeleted = false,
  }) async {
    final textQuery = query.trim().toLowerCase();
    final numberQuery = CustomerUtils.normalizePhone(query);

    return _customers.values.where((customer) {
      if (!includeDeleted && customer.isDeleted) {
        return false;
      }

      final matchesText = customer.name.toLowerCase().contains(textQuery) ||
          customer.membershipId.toLowerCase().contains(textQuery) ||
          customer.email.toLowerCase().contains(textQuery);

      final matchesNumber = numberQuery.isNotEmpty &&
          (customer.normalizedWhatsapp.contains(numberQuery) ||
              customer.normalizedPhone.contains(numberQuery));

      return matchesText || matchesNumber;
    }).toList();
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel customer) async {
    if (!_customers.containsKey(customer.id)) {
      throw StateError('Customer not found.');
    }

    final updated = customer.normalizeContactNumbers().copyWith(
          updatedAt: DateTime.now(),
        );

    _customers[updated.id] = updated;

    return updated;
  }

  @override
  Future<CustomerMutationResult> deleteCustomer(
    String customerId,
  ) async {
    final customer = _customers[customerId];

    if (customer == null) {
      return const CustomerMutationResult.failure(
        message: 'Customer not found.',
      );
    }

    final deleted = customer.markDeleted(
      deletedAt: DateTime.now(),
      deletedBy: 'fake-user',
    );

    _customers[customerId] = deleted;

    return CustomerMutationResult.success(
      message: 'Customer deleted.',
      value: deleted,
    );
  }

  @override
  Future<CustomerMutationResult> restoreCustomer(
    String customerId,
  ) async {
    final customer = _customers[customerId];

    if (customer == null) {
      return const CustomerMutationResult.failure(
        message: 'Customer not found.',
      );
    }

    final restored = customer.markRestored(
      restoredAt: DateTime.now(),
      restoredBy: 'fake-user',
    );

    _customers[customerId] = restored;

    return CustomerMutationResult.success(
      message: 'Customer restored.',
      value: restored,
    );
  }
}
