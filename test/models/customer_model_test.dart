import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/models/customer_model.dart';

void main() {
  group('CustomerModel constructor', () {
    test('creates customer with required and optional fields', () {
      final createdAt = DateTime(2026, 7, 18, 10);
      final updatedAt = DateTime(2026, 7, 18, 11);

      final customer = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Budi Santoso',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        phone: '0411123456',
        normalizedPhone: '62411123456',
        email: 'budi@example.com',
        address: 'Makassar',
        notes: 'Pelanggan grosir',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(customer.id, 'customer-1');
      expect(customer.membershipId, 'MBR-000001');
      expect(customer.name, 'Budi Santoso');
      expect(customer.whatsapp, '081234567890');
      expect(customer.normalizedWhatsapp, '6281234567890');
      expect(customer.phone, '0411123456');
      expect(customer.normalizedPhone, '62411123456');
      expect(customer.email, 'budi@example.com');
      expect(customer.address, 'Makassar');
      expect(customer.notes, 'Pelanggan grosir');
      expect(customer.createdAt, createdAt);
      expect(customer.updatedAt, updatedAt);
      expect(customer.isDeleted, isFalse);
      expect(customer.deletedAt, isNull);
      expect(customer.deletedBy, isEmpty);
      expect(customer.restoredAt, isNull);
      expect(customer.restoredBy, isEmpty);
    });

    test('uses an empty id when id is not supplied', () {
      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
      );

      expect(customer.id, isEmpty);
    });

    test('uses createdAt as updatedAt when updatedAt is absent', () {
      final createdAt = DateTime(2026, 7, 18);

      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        createdAt: createdAt,
      );

      expect(customer.updatedAt, createdAt);
    });

    test('provides correct defaults for optional fields', () {
      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
      );

      expect(customer.phone, isEmpty);
      expect(customer.normalizedPhone, isEmpty);
      expect(customer.email, isEmpty);
      expect(customer.address, isEmpty);
      expect(customer.notes, isEmpty);
      expect(customer.isDeleted, isFalse);
      expect(customer.deletedAt, isNull);
      expect(customer.deletedBy, isEmpty);
      expect(customer.restoredAt, isNull);
      expect(customer.restoredBy, isEmpty);
    });
  });

  group('CustomerModel serialization', () {
    test('toMap includes all customer fields', () {
      final createdAt = DateTime(2026, 7, 18, 10);
      final updatedAt = DateTime(2026, 7, 18, 11);
      final deletedAt = DateTime(2026, 7, 18, 12);
      final restoredAt = DateTime(2026, 7, 18, 13);

      final customer = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Budi Santoso',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        phone: '0411123456',
        normalizedPhone: '62411123456',
        email: 'budi@example.com',
        address: 'Makassar',
        notes: 'Pelanggan grosir',
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: true,
        deletedAt: deletedAt,
        deletedBy: 'owner@demo.local',
        restoredAt: restoredAt,
        restoredBy: 'admin@demo.local',
      );

      final map = customer.toMap();

      expect(map['id'], 'customer-1');
      expect(map['membershipId'], 'MBR-000001');
      expect(map['name'], 'Budi Santoso');
      expect(map['whatsapp'], '081234567890');
      expect(map['normalizedWhatsapp'], '6281234567890');
      expect(map['phone'], '0411123456');
      expect(map['normalizedPhone'], '62411123456');
      expect(map['email'], 'budi@example.com');
      expect(map['address'], 'Makassar');
      expect(map['notes'], 'Pelanggan grosir');
      expect(map['createdAt'], createdAt.toIso8601String());
      expect(map['updatedAt'], updatedAt.toIso8601String());
      expect(map['isDeleted'], isTrue);
      expect(map['deletedAt'], deletedAt.toIso8601String());
      expect(map['deletedBy'], 'owner@demo.local');
      expect(map['restoredAt'], restoredAt.toIso8601String());
      expect(map['restoredBy'], 'admin@demo.local');
    });

    test('round trip preserves customer data', () {
      final original = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Budi Santoso',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        phone: '0411123456',
        normalizedPhone: '62411123456',
        email: 'budi@example.com',
        address: 'Makassar',
        notes: 'Pelanggan grosir',
        createdAt: DateTime(2026, 7, 18, 10),
        updatedAt: DateTime(2026, 7, 18, 11),
      );

      final restored = CustomerModel.fromMap(
        original.id,
        original.toMap(),
      );

      expect(restored, original);
    });

    test('parses DateTime values directly', () {
      final createdAt = DateTime(2026, 7, 18, 10);

      final customer = CustomerModel.fromMap(
        'customer-1',
        {
          'membershipId': 'MBR-000001',
          'name': 'Customer',
          'whatsapp': '081234567890',
          'normalizedWhatsapp': '6281234567890',
          'createdAt': createdAt,
          'updatedAt': createdAt,
        },
      );

      expect(customer.createdAt, createdAt);
      expect(customer.updatedAt, createdAt);
    });

    test('parses millisecond timestamps', () {
      final value = DateTime(2026, 7, 18, 10);
      final timestamp = value.millisecondsSinceEpoch;

      final customer = CustomerModel.fromMap(
        'customer-1',
        {
          'membershipId': 'MBR-000001',
          'name': 'Customer',
          'whatsapp': '081234567890',
          'normalizedWhatsapp': '6281234567890',
          'createdAt': timestamp,
          'updatedAt': timestamp,
        },
      );

      expect(customer.createdAt, value);
      expect(customer.updatedAt, value);
    });

    test('handles null and empty values safely', () {
      final customer = CustomerModel.fromMap(
        'customer-1',
        {
          'name': null,
          'whatsapp': null,
          'normalizedWhatsapp': null,
          'createdAt': '',
          'updatedAt': null,
        },
      );

      expect(customer.id, 'customer-1');
      expect(customer.name, isEmpty);
      expect(customer.whatsapp, isEmpty);
      expect(customer.normalizedWhatsapp, isEmpty);
      expect(customer.createdAt, isNull);
    });
  });

  group('CustomerModel backward compatibility', () {
    test('moves legacy phone into WhatsApp fields', () {
      final customer = CustomerModel.fromMap(
        'legacy-customer',
        {
          'membershipId': 'MBR-000099',
          'name': 'Legacy Customer',
          'phone': '081234567890',
          'normalizedPhone': '6281234567890',
        },
      );

      expect(customer.whatsapp, '081234567890');
      expect(customer.normalizedWhatsapp, '6281234567890');
      expect(customer.phone, isEmpty);
      expect(customer.normalizedPhone, isEmpty);
    });

    test('keeps WhatsApp and alternate phone separated in new schema', () {
      final customer = CustomerModel.fromMap(
        'customer-1',
        {
          'membershipId': 'MBR-000001',
          'name': 'Customer',
          'whatsapp': '081234567890',
          'normalizedWhatsapp': '6281234567890',
          'phone': '0411123456',
          'normalizedPhone': '62411123456',
        },
      );

      expect(customer.whatsapp, '081234567890');
      expect(customer.normalizedWhatsapp, '6281234567890');
      expect(customer.phone, '0411123456');
      expect(customer.normalizedPhone, '62411123456');
    });
  });

  group('CustomerModel copyWith', () {
    final customer = CustomerModel(
      id: 'customer-1',
      membershipId: 'MBR-000001',
      name: 'Budi',
      whatsapp: '081234567890',
      normalizedWhatsapp: '6281234567890',
      phone: '0411123456',
      normalizedPhone: '62411123456',
      createdAt: DateTime(2026, 7, 18),
      deletedAt: DateTime(2026, 7, 19),
      restoredAt: DateTime(2026, 7, 20),
    );

    test('changes one field and preserves other fields', () {
      final result = customer.copyWith(name: 'Budi Santoso');

      expect(result.name, 'Budi Santoso');
      expect(result.id, customer.id);
      expect(result.membershipId, customer.membershipId);
      expect(result.whatsapp, customer.whatsapp);
    });

    test('changes WhatsApp and phone fields', () {
      final result = customer.copyWith(
        whatsapp: '081299999999',
        normalizedWhatsapp: '6281299999999',
        phone: '0411999999',
        normalizedPhone: '62411999999',
      );

      expect(result.whatsapp, '081299999999');
      expect(result.normalizedWhatsapp, '6281299999999');
      expect(result.phone, '0411999999');
      expect(result.normalizedPhone, '62411999999');
    });

    test('clears nullable date fields', () {
      final result = customer.copyWith(
        clearCreatedAt: true,
        clearDeletedAt: true,
        clearRestoredAt: true,
      );

      expect(result.createdAt, isNull);
      expect(result.deletedAt, isNull);
      expect(result.restoredAt, isNull);
    });
  });

  group('CustomerModel domain helpers', () {
    test('normalizes contact numbers', () {
      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: ' 0812-3456-7890 ',
        normalizedWhatsapp: '',
        phone: ' 0813-1111-2222 ',
        normalizedPhone: '',
      );

      final normalized = customer.normalizeContactNumbers();

      expect(normalized.whatsapp, '0812-3456-7890');
      expect(normalized.normalizedWhatsapp, '6281234567890');
      expect(normalized.phone, '0813-1111-2222');
      expect(normalized.normalizedPhone, '6281311112222');
    });

    test('marks customer as deleted', () {
      final deletedAt = DateTime(2026, 7, 18, 10);

      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
      );

      final deleted = customer.markDeleted(
        deletedAt: deletedAt,
        deletedBy: 'owner@demo.local',
      );

      expect(deleted.isDeleted, isTrue);
      expect(deleted.deletedAt, deletedAt);
      expect(deleted.deletedBy, 'owner@demo.local');
      expect(deleted.updatedAt, deletedAt);
      expect(deleted.restoredAt, isNull);
      expect(deleted.restoredBy, isEmpty);
    });

    test('restores a deleted customer', () {
      final restoredAt = DateTime(2026, 7, 18, 11);

      final customer = CustomerModel(
        membershipId: '',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        isDeleted: true,
        deletedAt: DateTime(2026, 7, 18, 10),
        deletedBy: 'owner@demo.local',
      );

      final restored = customer.markRestored(
        restoredAt: restoredAt,
        restoredBy: 'owner@demo.local',
      );

      expect(restored.isDeleted, isFalse);
      expect(restored.deletedAt, isNull);
      expect(restored.deletedBy, isEmpty);
      expect(restored.restoredAt, restoredAt);
      expect(restored.restoredBy, 'owner@demo.local');
      expect(restored.updatedAt, restoredAt);
    });
  });

  group('CustomerModel equality', () {
    test('models with equal data are equal', () {
      final updatedAt = DateTime(2026, 7, 18);

      final first = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        updatedAt: updatedAt,
      );

      final second = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Customer',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        updatedAt: updatedAt,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('models with different data are not equal', () {
      final updatedAt = DateTime(2026, 7, 18);

      final first = CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Customer A',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        updatedAt: updatedAt,
      );

      final second = first.copyWith(name: 'Customer B');

      expect(first, isNot(second));
    });
  });
}
