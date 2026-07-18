import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:postgetx/app/core/config/app_config.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/customer_model.dart';
import 'package:postgetx/app/data/models/expense_model.dart';
import 'package:postgetx/app/data/models/local_notification_model.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/data/models/order_lifecycle.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/core/services/loyalty_points_policy.dart';
import 'package:postgetx/app/core/services/product_image_service.dart';
import 'package:postgetx/app/core/helpers/customer_utils.dart';
import 'package:postgetx/app/data/repositories/auth_repository.dart';
import 'package:postgetx/app/data/providers/local/hive_loyalty_provider.dart';
import 'package:postgetx/app/data/repositories/local_loyalty_repository.dart';
import 'package:postgetx/app/data/repositories/loyalty_repository.dart';
import 'pos_operation_result.dart';
import 'pos_repository.dart';

typedef RepositoryWriteFaultInjector = void Function(String stage);

class LocalHiveRepository implements AuthRepository, PosRepository {
  static const _boxName = 'retail_pos_demo';
  static const currentSchemaVersion = 8;
  static const _sessionKey = 'currentSessionUserId';
  static const _customerSequenceKey = 'customerSequence';

  late Box<dynamic> _box;
  UserModel? _currentUser;
  final RepositoryWriteFaultInjector? _writeFaultInjector;
  LoyaltyConfiguration _loyaltyConfiguration;
  LoyaltyTierRules _loyaltyTierRules;
  bool _operationInProgress = false;

  LocalHiveRepository({
    RepositoryWriteFaultInjector? writeFaultInjector,
    LoyaltyConfiguration loyaltyConfiguration = LoyaltyConfiguration.defaults,
    LoyaltyTierRules loyaltyTierRules = LoyaltyTierRules.defaults,
  })  : _writeFaultInjector = writeFaultInjector,
        _loyaltyConfiguration = loyaltyConfiguration,
        _loyaltyTierRules = loyaltyTierRules;

  LocalHiveRepository.forBox(
    Box<dynamic> box, {
    RepositoryWriteFaultInjector? writeFaultInjector,
    LoyaltyConfiguration loyaltyConfiguration = LoyaltyConfiguration.defaults,
    LoyaltyTierRules loyaltyTierRules = LoyaltyTierRules.defaults,
  })  : _box = box,
        _writeFaultInjector = writeFaultInjector,
        _loyaltyConfiguration = loyaltyConfiguration,
        _loyaltyTierRules = loyaltyTierRules;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);

    if (_box.get('seedVersion') == null) {
      await resetDemoData();
    } else {
      await migrateSchema();
    }

    await restoreSession();
  }

  Future<void> migrateSchema() async {
    final version = (_box.get('seedVersion') as num?)?.toInt() ?? 0;

    if (version >= currentSchemaVersion) {
      await _ensureCompleteDemoSalesSeed();
      return;
    }

    final categories = _maps('categories').map((map) {
      return <String, dynamic>{
        ...map,
        'iconName': map['iconName']?.toString().trim().isNotEmpty == true
            ? map['iconName']
            : _seedIconName(map['name']?.toString()),
      };
    }).toList();

    final products = _maps('products').map((map) {
      final migrated = <String, dynamic>{
        ...map,
        'imageBase64': map['imageBase64']?.toString() ?? '',
        'imageMimeType': map['imageMimeType']?.toString() ?? '',
        'imageName': map['imageName']?.toString() ?? '',
      };

      migrated.remove('imageUrl');
      return migrated;
    }).toList();

    final transactions = _maps('transactions').map((map) {
      final status = map['status']?.toString() ?? OrderStatus.completed;

      final createdAt =
          map['createdAt']?.toString() ?? DateTime.now().toIso8601String();

      final legacyTax = (map['tax'] as num?)?.toDouble() ?? 0;
      final taxAmount = (map['taxAmount'] as num?)?.toDouble() ?? legacyTax;

      final migrated = <String, dynamic>{
        ...map,
        'status': status,
        'receiptStatus':
            map['receiptStatus']?.toString() ?? ReceiptState.printed,
        'taxType': map['taxType']?.toString() ??
            (taxAmount > 0 ? TaxType.fixedAmount.name : TaxType.none.name),
        'taxValue': (map['taxValue'] as num?)?.toDouble() ?? taxAmount,
        'taxAmount': taxAmount,
        'completedAt': map['completedAt'] ??
            (status == OrderStatus.completed ? createdAt : null),
        'cancelledAt': map['cancelledAt'],
        'refundedAt': map['refundedAt'],
        'refundReason': map['refundReason'],
        'stockApplied':
            map['stockApplied'] as bool? ?? status == OrderStatus.completed,
        'stockRestored':
            map['stockRestored'] as bool? ?? status == OrderStatus.refunded,
        'sourceOrderId': map['sourceOrderId'],
        'updatedAt': map['updatedAt'] ?? createdAt,
        'createdByName': map['createdByName']?.toString() ?? '',
        'updatedBy': map['updatedBy']?.toString() ?? '',
        'cancelledBy': map['cancelledBy'],
        'cancellationReason': map['cancellationReason'],
        'refundedBy': map['refundedBy'],
        'paymentMethod': map['paymentMethod']?.toString() ?? 'cash',
        'amountReceived': (map['amountReceived'] as num?)?.toDouble() ??
            (map['paid'] as num?)?.toDouble() ??
            0,
        'amountApplied': (map['amountApplied'] as num?)?.toDouble() ??
            (map['totalAmount'] as num?)?.toDouble() ??
            0,
        'paidAt': map['paidAt'] ??
            (status == OrderStatus.completed ? createdAt : null),
        'customerId': map['customerId'],
        'customerName': map['customerName'],
        'notes': map['notes']?.toString() ?? '',
        'isDeleted': map['isDeleted'] as bool? ?? false,
        'deletedAt': map['deletedAt'],
        'deletedBy': map['deletedBy'],
        'deleteReason': map['deleteReason'],
        'restoredAt': map['restoredAt'],
        'restoredBy': map['restoredBy'],
      };

      migrated.remove('tax');
      return migrated;
    }).toList();

    final customers = _maps('customers').asMap().entries.map((entry) {
      final index = entry.key;
      final map = entry.value;

      final id = map['id']?.toString() ??
          map['uid']?.toString() ??
          'customer-${index + 1}';

      final phone = map['phone']?.toString() ?? '';

      final whatsapp = map['whatsapp']?.toString() ?? '';

      final createdAt =
          map['createdAt']?.toString() ?? DateTime.now().toIso8601String();

      return <String, dynamic>{
        ...map,
        'id': id,
        'membershipId':
            map['membershipId']?.toString().trim().isNotEmpty == true
                ? map['membershipId'].toString()
                : CustomerUtils.generateMembershipId(index + 1),
        'name': map['name']?.toString() ?? '',
        'phone': phone,
        'normalizedPhone':
            map['normalizedPhone']?.toString().trim().isNotEmpty == true
                ? map['normalizedPhone'].toString()
                : CustomerUtils.normalizePhone(phone),
        'whatsapp': whatsapp,
        'normalizedWhatsapp':
            map['normalizedWhatsapp']?.toString().trim().isNotEmpty == true
                ? map['normalizedWhatsapp'].toString()
                : CustomerUtils.normalizePhone(whatsapp),
        'email': map['email']?.toString() ?? '',
        'address': map['address']?.toString() ?? '',
        'notes': map['notes']?.toString() ?? '',
        'createdAt': createdAt,
        'updatedAt': map['updatedAt']?.toString() ?? createdAt,
        'isDeleted': map['isDeleted'] as bool? ?? false,
        'deletedAt': map['deletedAt'],
        'deletedBy': map['deletedBy']?.toString() ?? '',
        'restoredAt': map['restoredAt'],
        'restoredBy': map['restoredBy']?.toString() ?? '',
      };
    }).toList();

    await _putMaps('categories', categories);
    await _putMaps('products', products);
    await _putMaps('transactions', transactions);
    await _putMaps('customers', customers);

    if (!_box.containsKey('users')) {
      await _seedDemoUsers();
    }

    if (!_box.containsKey('notifications')) {
      await _putMaps('notifications', const []);
    }

    if (!_box.containsKey('expenses')) {
      await _putMaps('expenses', const []);
    }

    if (!_box.containsKey(HiveLoyaltyProvider.storageKey)) {
      await HiveLoyaltyProvider(_box).clear();
    }

    if (!_box.containsKey(_customerSequenceKey)) {
      await _box.put(_customerSequenceKey, customers.length);
    }

    await _box.put('seedVersion', currentSchemaVersion);
    await _ensureCompleteDemoSalesSeed();
  }

  static String _seedIconName(String? name) => switch (name) {
        'Beverages' => 'beverages',
        'Snacks' => 'snacks',
        'Grocery' => 'grocery',
        'Personal Care' => 'personalCare',
        'Household' => 'household',
        _ => 'other',
      };

  Future<void> _ensureCompleteDemoSalesSeed() async {
    final transactions = _maps('transactions');
    final ids = transactions.map((map) => map['id']?.toString()).toSet();

    const originalDemoIds = {
      'seed-1',
      'seed-2',
      'seed-3',
      'seed-4',
      'seed-5',
    };

    if (!ids.containsAll(originalDemoIds) || ids.contains('seed-6')) {
      return;
    }

    final seedFive = transactions.firstWhere(
      (map) => map['id'] == 'seed-5',
    );

    final seedFiveTime =
        DateTime.tryParse(seedFive['createdAt']?.toString() ?? '') ??
            DateTime.now().subtract(const Duration(hours: 5));

    final order = OrderModel(
      id: 'seed-6',
      orderId: 'DEMO-1006',
      items: [
        CartItemModel(
          id: 'snickers',
          name: 'Snickers 50g',
          size: 'Regular',
          price: 17500,
          quantity: 2,
        ),
      ],
      totalAmount: 35000,
      discount: 0,
      paid: 35000,
      change: 0,
      createdAt: seedFiveTime.subtract(const Duration(hours: 1)),
      createdBy: 'demo-admin',
    );

    transactions.add({
      'id': order.id,
      ...order.toMap(),
      'createdAt': order.createdAt.toIso8601String(),
    });

    await _putMaps('transactions', transactions);
  }

  @override
  UserModel? get currentUser => _currentUser;

  LoyaltyConfiguration get loyaltyConfiguration => _loyaltyConfiguration;

  void applyLoyaltyConfiguration(
    LoyaltyConfiguration configuration,
  ) {
    final errors = configuration.validate();

    if (errors.isNotEmpty) {
      throw FormatException(errors.join(' '));
    }

    _loyaltyConfiguration = configuration;
  }

  LoyaltyTierRules get loyaltyTierRules => _loyaltyTierRules;

  void applyLoyaltyTierRules(LoyaltyTierRules rules) {
    final errors = rules.validate();

    if (errors.isNotEmpty) {
      throw FormatException(errors.join(' '));
    }

    _loyaltyTierRules = rules;
  }

  LoyaltyRepository get loyaltyRepository => LocalLoyaltyRepository(
        HiveLoyaltyProvider(_box),
        actorId: () => _currentUser?.id ?? 'system',
        configuration: () => _loyaltyConfiguration,
        tierRules: () => _loyaltyTierRules,
        lifetimeEligibleSpend: (customerId) {
          return _maps('transactions')
              .where(
                (map) =>
                    map['customerId']?.toString() == customerId &&
                    map['status']?.toString() == OrderStatus.completed &&
                    !(map['isDeleted'] as bool? ?? false),
              )
              .fold<double>(
                0,
                (total, map) =>
                    total + ((map['totalAmount'] as num?)?.toDouble() ?? 0),
              );
        },
      );

  static String demoPasswordHash(String password) {
    return sha256
        .convert(
          utf8.encode('malprax-demo-v1:$password'),
        )
        .toString();
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final users = _maps('users')
        .map(
          (map) => UserModel.fromMap(
            map['id']?.toString() ?? '',
            map,
          ),
        )
        .toList();

    final normalizedEmail = email.trim().toLowerCase();
    final passwordHash = demoPasswordHash(password);

    _currentUser = users
        .where(
          (user) =>
              user.isActive &&
              user.email.toLowerCase() == normalizedEmail &&
              user.passwordHash == passwordHash,
        )
        .firstOrNull;

    if (_currentUser == null) {
      throw const FormatException(
        'Use one of the visible demo accounts.',
      );
    }

    await _box.put(_sessionKey, _currentUser!.id);
    return _currentUser!;
  }

  @override
  Future<UserModel?> restoreSession() async {
    final id = _box.get(_sessionKey)?.toString();

    if (id == null || id.isEmpty) {
      return null;
    }

    _currentUser = _maps('users')
        .map(
          (map) => UserModel.fromMap(
            map['id']?.toString() ?? '',
            map,
          ),
        )
        .where(
          (user) => user.id == id && user.isActive,
        )
        .firstOrNull;

    if (_currentUser == null) {
      await _box.delete(_sessionKey);
    }

    return _currentUser;
  }

  @override
  bool hasPermission(AppPermission permission) {
    return RolePermissions.allows(
      _currentUser?.role,
      permission,
    );
  }

  PosOperationResult<T> _permissionDenied<T>(
    AppPermission permission,
  ) {
    return PosOperationResult.failure(
      'permission_denied',
      'Your ${_currentUser?.role ?? 'signed-out'} role cannot perform '
          '${permission.name}.',
    );
  }

  void _requirePermission(AppPermission permission) {
    if (!hasPermission(permission)) {
      throw StateError(
        'Permission denied: ${permission.name} is not available for this role.',
      );
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _box.delete(_sessionKey);
  }

  List<Map<String, dynamic>> _maps(String key) {
    return (_box.get(
      key,
      defaultValue: const <dynamic>[],
    ) as List)
        .map(
          (item) => Map<String, dynamic>.from(
            item as Map,
          ),
        )
        .toList();
  }

  Future<void> _putMaps(
    String key,
    Iterable<Map<String, dynamic>> value,
  ) {
    return _box.put(key, value.toList());
  }

  int _currentCustomerSequence() {
    return (_box.get(_customerSequenceKey) as num?)?.toInt() ?? 0;
  }

  Future<int> _nextCustomerSequence() async {
    final next = _currentCustomerSequence() + 1;
    await _box.put(_customerSequenceKey, next);
    return next;
  }

  String _customerMapId(Map<String, dynamic> map) {
    return map['id']?.toString() ?? map['uid']?.toString() ?? '';
  }

  CustomerModel _customerFromMap(Map<String, dynamic> map) {
    return CustomerModel.fromMap(
      _customerMapId(map),
      map,
    );
  }

  void _validateCustomer(
    CustomerModel customer,
    List<Map<String, dynamic>> values, {
    required bool isCreating,
  }) {
    if (customer.name.trim().isEmpty) {
      throw const FormatException(
        'Customer name is required.',
      );
    }

    final normalizedPhone = CustomerUtils.normalizePhone(
      customer.phone,
    );

    final normalizedWhatsapp = CustomerUtils.normalizePhone(
      customer.whatsapp,
    );

    if (customer.phone.trim().isNotEmpty && normalizedPhone.length < 10) {
      throw const FormatException(
        'Customer phone number is invalid.',
      );
    }

    if (customer.whatsapp.trim().isNotEmpty && normalizedWhatsapp.length < 10) {
      throw const FormatException(
        'Customer WhatsApp number is invalid.',
      );
    }

    if (!isCreating && customer.id.trim().isEmpty) {
      throw const FormatException(
        'Customer ID is required.',
      );
    }

    if (normalizedPhone.isNotEmpty) {
      final duplicatePhone = values.any((map) {
        final existingId = _customerMapId(map);

        final existingPhone = CustomerUtils.normalizePhone(
          map['normalizedPhone']?.toString() ?? map['phone']?.toString() ?? '',
        );

        final isDeleted = map['isDeleted'] as bool? ?? false;

        return existingId != customer.id &&
            existingPhone.isNotEmpty &&
            existingPhone == normalizedPhone &&
            !isDeleted;
      });

      if (duplicatePhone) {
        throw const FormatException(
          'A customer with this phone number already exists.',
        );
      }
    }

    if (normalizedWhatsapp.isNotEmpty) {
      final duplicateWhatsapp = values.any((map) {
        final existingId = _customerMapId(map);

        final existingWhatsapp = CustomerUtils.normalizePhone(
          map['normalizedWhatsapp']?.toString() ??
              map['whatsapp']?.toString() ??
              '',
        );

        final isDeleted = map['isDeleted'] as bool? ?? false;

        return existingId != customer.id &&
            existingWhatsapp.isNotEmpty &&
            existingWhatsapp == normalizedWhatsapp &&
            !isDeleted;
      });

      if (duplicateWhatsapp) {
        throw const FormatException(
          'A customer with this WhatsApp number already exists.',
        );
      }
    }
  }

  Future<void> _seedDemoUsers() async {
    final now = DateTime.now();

    await _putMaps('users', [
      UserModel(
        id: 'demo-owner',
        email: AppConfig.ownerEmail,
        name: 'Demo Owner',
        role: UserRole.owner,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        passwordHash: demoPasswordHash(
          AppConfig.ownerPassword,
        ),
      ).toMap(),
      UserModel(
        id: 'demo-staff',
        email: AppConfig.staffEmail,
        name: 'Demo Staff',
        role: UserRole.staff,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        passwordHash: demoPasswordHash(
          AppConfig.staffPassword,
        ),
      ).toMap(),
    ]);
  }

  Future<List<UserModel>> getUsers() async {
    final users = _maps('users')
        .map(
          (map) => UserModel.fromMap(
            map['id']?.toString() ?? map['uid']?.toString() ?? '',
            map,
          ),
        )
        .toList();

    users.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return users;
  }

  Future<void> saveUser(UserModel user) async {
    final values = _maps('users');

    if (user.name.trim().isEmpty) {
      throw const FormatException(
        'User name is required.',
      );
    }

    if (user.email.trim().isEmpty || !user.email.contains('@')) {
      throw const FormatException(
        'A valid user email is required.',
      );
    }

    final normalizedEmail = user.email.trim().toLowerCase();

    final duplicateEmail = values.any(
      (map) =>
          (map['id']?.toString() ?? map['uid']?.toString()) != user.id &&
          map['email']?.toString().trim().toLowerCase() == normalizedEmail,
    );

    if (duplicateEmail) {
      throw const FormatException(
        'User email already exists.',
      );
    }

    final existingIndex = values.indexWhere(
      (map) =>
          map['id']?.toString() == user.id || map['uid']?.toString() == user.id,
    );

    final existing = existingIndex >= 0
        ? UserModel.fromMap(
            user.id,
            values[existingIndex],
          )
        : null;

    final now = DateTime.now();

    final saved = UserModel(
      id: user.id.trim().isEmpty
          ? 'user-${now.microsecondsSinceEpoch}'
          : user.id,
      email: normalizedEmail,
      name: user.name.trim(),
      role: user.role,
      isActive: user.isActive,
      createdAt: existing?.createdAt ?? user.createdAt ?? now,
      updatedAt: now,
      passwordHash: user.passwordHash.isNotEmpty
          ? user.passwordHash
          : existing?.passwordHash ?? demoPasswordHash('demo123'),
      photoUrl:
          user.photoUrl.isNotEmpty ? user.photoUrl : existing?.photoUrl ?? '',
    );

    if (existingIndex < 0) {
      values.add(saved.toMap());
    } else {
      values[existingIndex] = saved.toMap();
    }

    await _putMaps('users', values);

    if (_currentUser?.id == saved.id) {
      _currentUser = saved;
    }
  }

  Future<void> deleteUser(String id) async {
    if (_currentUser?.id == id) {
      throw StateError(
        'The currently signed-in user cannot be deleted.',
      );
    }

    final values = _maps('users')
      ..removeWhere(
        (map) => map['id']?.toString() == id || map['uid']?.toString() == id,
      );

    await _putMaps('users', values);
  }

  Future<void> _notify({
    required String type,
    required String title,
    required String message,
    required String entityType,
    required String entityId,
    required String route,
    String severity = 'info',
  }) async {
    try {
      final actor = _currentUser;

      final notification = LocalNotificationModel(
        id: 'notification-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        title: title,
        message: message,
        entityType: entityType,
        entityId: entityId,
        route: route,
        createdAt: DateTime.now(),
        isRead: false,
        actorId: actor?.id ?? 'system',
        actorName: actor?.name ?? 'System',
        severity: severity,
      );

      final values = _maps('notifications')..add(notification.toMap());

      if (values.length > 200) {
        values.removeRange(
          0,
          values.length - 200,
        );
      }

      await _putMaps('notifications', values);
    } catch (_) {
      // Notifications are secondary and must not roll back successful actions.
    }
  }

  Future<void> _notifyStockTransitions(
    List<Map<String, dynamic>> before,
    List<Map<String, dynamic>> after,
  ) async {
    for (final current in after) {
      final previous = before
          .where(
            (item) => item['id'] == current['id'],
          )
          .firstOrNull;

      if (previous == null) {
        continue;
      }

      final previousStock = (previous['stock'] as num?)?.toInt() ?? 0;

      final stock = (current['stock'] as num?)?.toInt() ?? 0;

      final threshold = (current['lowStockThreshold'] as num?)?.toInt() ?? 5;

      final crossedOutOfStock = previousStock > 0 && stock == 0;

      final crossedLowStock =
          previousStock > threshold && stock > 0 && stock <= threshold;

      if (!crossedOutOfStock && !crossedLowStock) {
        continue;
      }

      await _notify(
        type: crossedOutOfStock ? 'outOfStock' : 'lowStock',
        title:
            crossedOutOfStock ? 'Product out of stock' : 'Low stock detected',
        message: crossedOutOfStock
            ? '${current['name']} is out of stock.'
            : '${current['name']} has $stock item(s) left.',
        entityType: 'product',
        entityId: current['id']?.toString() ?? '',
        route: '/cashier/inventory',
        severity: 'warning',
      );
    }
  }

  @override
  Future<List<LocalNotificationModel>> getNotifications({
    int? limit,
  }) async {
    final values =
        _maps('notifications').map(LocalNotificationModel.fromMap).toList()
          ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );

    return limit == null ? values : values.take(limit).toList();
  }

  @override
  Future<void> markNotificationRead(
    String id, {
    required bool isRead,
  }) async {
    final values = _maps('notifications');
    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index < 0) {
      return;
    }

    values[index] = {
      ...values[index],
      'isRead': isRead,
      'readAt': isRead ? DateTime.now().toIso8601String() : null,
    };

    await _putMaps('notifications', values);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    final now = DateTime.now().toIso8601String();

    await _putMaps(
      'notifications',
      _maps('notifications').map(
        (map) => {
          ...map,
          'isRead': true,
          'readAt': map['readAt'] ?? now,
        },
      ),
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return _maps('categories')
        .map(
          (map) => CategoryModel.fromMap(
            map['id'] as String,
            map,
          ),
        )
        .toList();
  }

  @override
  Future<CategoryModel> addCategory(
    String name, {
    String iconName = 'other',
  }) async {
    _requirePermission(AppPermission.manageCategories);

    final item = CategoryModel(
      id: 'cat-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      iconName: iconName,
    );

    final values = _maps('categories')
      ..add({
        'id': item.id,
        ...item.toMap(),
      });

    await _putMaps('categories', values);
    return item;
  }

  @override
  Future<void> updateCategory(
    String id,
    String name, {
    String iconName = 'other',
  }) async {
    _requirePermission(AppPermission.manageCategories);

    final values = _maps('categories');

    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index >= 0) {
      values[index] = {
        ...values[index],
        'name': name,
        'iconName': iconName,
      };
    }

    await _putMaps('categories', values);
  }

  @override
  Future<void> deleteCategory(String id) async {
    _requirePermission(AppPermission.manageCategories);

    await _putMaps(
      'categories',
      _maps('categories')
        ..removeWhere(
          (map) => map['id'] == id,
        ),
    );
  }

  @override
  Future<List<MenuItemModel>> getProducts() async {
    return _maps('products')
        .map(
          (map) => MenuItemModel.fromMap(
            map['id'] as String,
            map,
          ),
        )
        .toList();
  }

  @override
  Future<MenuItemModel> addProduct({
    required String name,
    required String categoryId,
    required String categoryName,
    required List<MenuVariant> variants,
    String sku = '',
    int stock = 0,
    int lowStockThreshold = 5,
    String imageBase64 = '',
    String imageMimeType = '',
    String imageName = '',
  }) async {
    _requirePermission(AppPermission.manageProducts);

    if (_maps('products').length >= AppConfig.maxDemoProducts) {
      throw StateError(
        'Demo product limit reached. Reset demo data to continue.',
      );
    }

    final item = MenuItemModel(
      id: 'product-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      variants: variants,
      sku: sku,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      imageBase64: imageBase64,
      imageMimeType: imageMimeType,
      imageName: imageName,
    );

    final values = _maps('products');

    _validateProduct(item, values);

    values.add({
      'id': item.id,
      ...item.toMap(),
    });

    await _putMaps('products', values);

    await _notify(
      type: 'productCreated',
      title: 'Product created',
      message: item.name,
      entityType: 'product',
      entityId: item.id,
      route: '/cashier/products',
      severity: 'success',
    );

    return item;
  }

  @override
  Future<void> updateProduct(MenuItemModel product) async {
    _requirePermission(AppPermission.manageProducts);

    final values = _maps('products');

    _validateProduct(product, values);

    final index = values.indexWhere(
      (map) => map['id'] == product.id,
    );

    if (index >= 0) {
      values[index] = {
        'id': product.id,
        ...product.toMap(),
      };
    }

    await _putMaps('products', values);

    await _notify(
      type: 'productUpdated',
      title: 'Product updated',
      message: product.name,
      entityType: 'product',
      entityId: product.id,
      route: '/cashier/products',
    );
  }

  void _validateProduct(
    MenuItemModel product,
    List<Map<String, dynamic>> values,
  ) {
    if (product.name.trim().isEmpty) {
      throw const FormatException(
        'Product name is required.',
      );
    }

    if (product.sku.trim().isEmpty) {
      throw const FormatException(
        'SKU is required.',
      );
    }

    if (values.any(
      (map) =>
          map['id'] != product.id &&
          map['sku']?.toString().toLowerCase() == product.sku.toLowerCase(),
    )) {
      throw const FormatException(
        'SKU must be unique.',
      );
    }

    if (product.categoryId.trim().isEmpty) {
      throw const FormatException(
        'Category is required.',
      );
    }

    if (product.variants.isEmpty ||
        product.variants.any(
          (variant) => !variant.price.isFinite || variant.price <= 0,
        )) {
      throw const FormatException(
        'Price must be greater than zero.',
      );
    }

    if (product.variants.any(
      (variant) => !variant.costPrice.isFinite || variant.costPrice < 0,
    )) {
      throw const FormatException(
        'Cost price cannot be negative.',
      );
    }

    if (product.stock < 0 || product.lowStockThreshold < 0) {
      throw const FormatException(
        'Stock values cannot be negative.',
      );
    }

    if (product.imageBase64.isNotEmpty &&
        !{
          'image/jpeg',
          'image/png',
          'image/webp',
        }.contains(product.imageMimeType)) {
      throw const FormatException(
        'Product image metadata is invalid.',
      );
    }

    if (product.imageBase64.isNotEmpty) {
      try {
        final decodedSize = ProductImageService.decodedStoredSize(
          product.imageBase64,
        );

        if (decodedSize == 0 ||
            decodedSize > ProductImageService.maxStoredSizeBytes) {
          throw const FormatException(
            'Product image must be an optimized local image.',
          );
        }
      } on FormatException {
        throw const FormatException(
          'Product image data is invalid.',
        );
      }
    }
  }

  @override
  Future<void> adjustStock(
    String productId,
    int quantityDelta,
  ) async {
    _requirePermission(AppPermission.manageInventory);

    final values = _maps('products');

    final index = values.indexWhere(
      (map) => map['id'] == productId,
    );

    if (index < 0) {
      return;
    }

    final before = values
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();

    final current = (values[index]['stock'] as num?)?.toInt() ?? 0;

    values[index]['stock'] = (current + quantityDelta).clamp(0, 999999);

    await _putMaps('products', values);
    await _notifyStockTransitions(before, values);
  }

  @override
  Future<void> deleteProduct(String id) async {
    _requirePermission(AppPermission.manageProducts);

    await _putMaps(
      'products',
      _maps('products')
        ..removeWhere(
          (map) => map['id'] == id,
        ),
    );
  }

  @override
  Future<List<OrderModel>> getTransactions({
    bool includeDeleted = false,
  }) async {
    final values = _maps('transactions')
        .map(
          (map) => OrderModel.fromMap(
            map['id'] as String,
            map,
          ),
        )
        .where(
          (order) => includeDeleted || !order.isDeleted,
        )
        .toList();

    values.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return values;
  }

  Map<String, dynamic> _orderMap(OrderModel order) {
    return {
      'id': order.id,
      ...order.toMap(),
      'createdAt': order.createdAt.toIso8601String(),
    };
  }

  void _upsertOrder(
    List<Map<String, dynamic>> values,
    OrderModel order,
  ) {
    final index = values.indexWhere(
      (map) => map['id'] == order.id,
    );

    if (index < 0) {
      values.add(_orderMap(order));
    } else {
      values[index] = _orderMap(order);
    }
  }

  PosOperationResult<OrderModel>? _validateSale(
    OrderModel order,
    List<Map<String, dynamic>> productMaps,
  ) {
    if (order.items.isEmpty) {
      return PosOperationResult.failure(
        'empty_cart',
        'Add at least one product before checkout.',
      );
    }

    if (order.id.trim().isEmpty || order.orderId.trim().isEmpty) {
      return PosOperationResult.failure(
        'invalid_id',
        'Transaction ID is required.',
      );
    }

    final quantities = <String, int>{};

    for (final item in order.items) {
      if (item.id.trim().isEmpty ||
          !productMaps.any(
            (map) => map['id'] == item.id,
          )) {
        return PosOperationResult.failure(
          'product_missing',
          'Product ${item.name} is no longer available.',
        );
      }

      if (item.quantity <= 0) {
        return PosOperationResult.failure(
          'invalid_quantity',
          'Product quantities must be greater than zero.',
        );
      }

      if (item.price < 0) {
        return PosOperationResult.failure(
          'invalid_price',
          'Product prices cannot be negative.',
        );
      }

      quantities[item.id] = (quantities[item.id] ?? 0) + item.quantity;
    }

    if (order.discountValue < 0 ||
        (order.discountType == DiscountType.percentage &&
            order.discountValue > 100)) {
      return PosOperationResult.failure(
        'invalid_discount',
        'Discount must be a non-negative amount or a percentage from 0 to 100.',
      );
    }

    if (!order.taxValue.isFinite ||
        order.taxValue < 0 ||
        (order.taxType == TaxType.percentage && order.taxValue > 100) ||
        (order.taxType == TaxType.none && order.taxValue != 0)) {
      return PosOperationResult.failure(
        'invalid_tax',
        'Tax must be none, a non-negative amount, or a percentage from 0 to 100.',
      );
    }

    final expected = const PosTotalCalculator().calculate(
      items: order.items,
      discountType: order.discountType,
      discountValue: order.discountValue,
      loyaltyDiscount: order.loyaltyDiscount,
      taxType: order.taxType,
      taxValue: order.taxValue,
      amountPaid: order.amountReceived,
    );

    final totalsMatch = PosTotalCalculator.sameMoney(
          order.subtotal,
          expected.subtotal,
        ) &&
        PosTotalCalculator.sameMoney(
          order.discount,
          expected.discountAmount,
        ) &&
        PosTotalCalculator.sameMoney(
          order.loyaltyDiscount,
          expected.loyaltyDiscount,
        ) &&
        PosTotalCalculator.sameMoney(
          order.taxableAmount,
          expected.taxableAmount,
        ) &&
        PosTotalCalculator.sameMoney(
          order.taxAmount,
          expected.taxAmount,
        ) &&
        PosTotalCalculator.sameMoney(
          order.totalAmount,
          expected.total,
        ) &&
        PosTotalCalculator.sameMoney(
          order.amountApplied,
          expected.total,
        ) &&
        PosTotalCalculator.sameMoney(
          order.paid,
          order.amountReceived,
        ) &&
        PosTotalCalculator.sameMoney(
          order.change,
          expected.change,
        );

    if (!totalsMatch || !order.totalAmount.isFinite || order.totalAmount < 0) {
      return PosOperationResult.failure(
        'total_mismatch',
        'Checkout totals changed. Review the cart and try again.',
      );
    }

    if (order.paymentMethod != 'cash') {
      return PosOperationResult.failure(
        'payment_method_unavailable',
        'Cash is the only enabled payment method in the offline demo.',
      );
    }

    if (!order.amountReceived.isFinite ||
        order.amountReceived < order.totalAmount) {
      return PosOperationResult.failure(
        'payment_insufficient',
        'Payment is less than the transaction total.',
      );
    }

    for (final entry in quantities.entries) {
      final map = productMaps.firstWhere(
        (product) => product['id'] == entry.key,
      );

      final stock = (map['stock'] as num?)?.toInt() ?? 0;

      if (stock < entry.value) {
        return PosOperationResult.failure(
          'insufficient_stock',
          '${map['name']} only has $stock item(s) available.',
        );
      }
    }

    return null;
  }

  Future<PosOperationResult<OrderModel>?> _validateCheckoutLoyalty(
      OrderModel order) async {
    if (order.loyaltyPointsRedeemed < 0 ||
        !order.loyaltyDiscount.isFinite ||
        order.loyaltyDiscount < 0) {
      return PosOperationResult.failure(
        'invalid_loyalty_redemption',
        'Loyalty points and discount cannot be negative.',
      );
    }

    if (order.loyaltyPointsRedeemed == 0) {
      if (!PosTotalCalculator.sameMoney(
        order.loyaltyDiscount,
        0,
      )) {
        return PosOperationResult.failure(
          'loyalty_discount_mismatch',
          'A loyalty discount requires redeemed points.',
        );
      }

      return null;
    }

    final customerId = order.customerId?.trim() ?? '';

    if (customerId.isEmpty) {
      return PosOperationResult.failure(
        'loyalty_customer_required',
        'Select a customer before redeeming loyalty points.',
      );
    }

    final configuration = _loyaltyConfiguration;

    if (!configuration.isEnabled) {
      return PosOperationResult.failure(
        'loyalty_disabled',
        'Loyalty redemption is currently disabled.',
      );
    }

    final expectedDiscount = LoyaltyPointsPolicy.redemptionValue(
      order.loyaltyPointsRedeemed,
      isEnabled: configuration.isEnabled,
      valuePerPoint: configuration.redeemValuePerPoint,
    );

    if (!PosTotalCalculator.sameMoney(
      order.loyaltyDiscount,
      expectedDiscount,
    )) {
      return PosOperationResult.failure(
        'loyalty_discount_mismatch',
        'The loyalty discount does not match the redeemed points.',
      );
    }

    final balance = await loyaltyRepository.getBalance(customerId);

    final payableBeforeLoyalty = order.taxableAmount + order.loyaltyDiscount;

    final maximumPoints = LoyaltyPointsPolicy.maximumRedeemablePoints(
      availablePoints: balance,
      payableAmount: payableBeforeLoyalty,
      valuePerPoint: configuration.redeemValuePerPoint,
      maximumRedemptionPercentage: configuration.maximumRedemptionPercentage,
      isEnabled: configuration.isEnabled,
    );

    if (balance < order.loyaltyPointsRedeemed) {
      return PosOperationResult.failure(
        'insufficient_loyalty_points',
        'The customer does not have enough loyalty points.',
      );
    }

    if (order.loyaltyPointsRedeemed > maximumPoints) {
      return PosOperationResult.failure(
        'loyalty_redemption_limit_exceeded',
        'Redeemed points exceed the configured transaction limit.',
      );
    }

    return null;
  }

  @override
  Future<PosOperationResult<OrderModel>> completeSale(
    OrderModel order,
  ) async {
    if (!hasPermission(AppPermission.createTransaction)) {
      return _permissionDenied(
        AppPermission.createTransaction,
      );
    }

    if (_operationInProgress) {
      return PosOperationResult.failure(
        'operation_busy',
        'Another checkout is still being processed.',
      );
    }

    _operationInProgress = true;

    final productSnapshot = _maps('products');
    final orderSnapshot = _maps('transactions');
    final loyaltySnapshot = _maps(HiveLoyaltyProvider.storageKey);

    try {
      if (order.status != OrderStatus.draft &&
          !OrderStatus.open.contains(order.status)) {
        return PosOperationResult.failure(
          'invalid_completion_status',
          'Only a draft, held, or saved order can be completed.',
        );
      }

      final existingMap = orderSnapshot
          .where(
            (map) => map['id'] == order.id || map['orderId'] == order.orderId,
          )
          .firstOrNull;

      if (existingMap != null) {
        final existing = OrderModel.fromMap(
          existingMap['id'] as String,
          existingMap,
        );

        if (existing.status == OrderStatus.completed ||
            existing.status == OrderStatus.refunded ||
            existing.stockApplied) {
          return PosOperationResult.failure(
            'already_completed',
            'This transaction has already been completed.',
          );
        }

        if (!OrderStatus.open.contains(existing.status)) {
          return PosOperationResult.failure(
            'order_closed',
            'A cancelled transaction cannot be completed. Create a new sale.',
          );
        }
      }

      if (orderSnapshot.any(
        (map) => map['orderId'] == order.orderId && map['id'] != order.id,
      )) {
        return PosOperationResult.failure(
          'duplicate_transaction_id',
          'Transaction ID already exists.',
        );
      }

      final validation = _validateSale(
        order,
        productSnapshot,
      );

      if (validation != null) {
        return validation;
      }

      final loyaltyValidation = await _validateCheckoutLoyalty(order);

      if (loyaltyValidation != null) {
        return loyaltyValidation;
      }

      final quantities = <String, int>{};

      for (final item in order.items) {
        quantities[item.id] = (quantities[item.id] ?? 0) + item.quantity;
      }

      final updatedProducts = productSnapshot
          .map(
            (map) => Map<String, dynamic>.from(map),
          )
          .toList();

      for (final entry in quantities.entries) {
        final index = updatedProducts.indexWhere(
          (map) => map['id'] == entry.key,
        );

        updatedProducts[index]['stock'] =
            (updatedProducts[index]['stock'] as num).toInt() - entry.value;
      }

      final now = DateTime.now();
      final actor = _currentUser!;
      final customerId = order.customerId?.trim() ?? '';

      final loyaltyBalanceBefore = customerId.isEmpty
          ? 0
          : await loyaltyRepository.getBalance(customerId);

      final baseLoyaltyPoints = customerId.isEmpty
          ? 0
          : LoyaltyPointsPolicy.earnedPoints(
              order.totalAmount,
              isEnabled: _loyaltyConfiguration.isEnabled,
              spendingRequired: _loyaltyConfiguration.spendPerPoint,
              minimumEligibleTransaction:
                  _loyaltyConfiguration.minimumEligibleTransaction,
            );

      final tierProfileBefore = customerId.isEmpty
          ? null
          : await loyaltyRepository.getTierProfile(customerId);

      final projectedLifetimeSpend =
          (tierProfileBefore?.lifetimeEligibleSpend ?? 0) + order.totalAmount;

      final projectedTier = _loyaltyTierRules.resolve(projectedLifetimeSpend);

      final loyaltyPointsEarned = customerId.isEmpty
          ? 0
          : _loyaltyTierRules.rewardedPoints(
              basePoints: baseLoyaltyPoints,
              tier: projectedTier,
            );

      final loyaltyBalanceAfter = loyaltyBalanceBefore -
          order.loyaltyPointsRedeemed +
          loyaltyPointsEarned;

      final completed = order.copyWith(
        loyaltyPointsEarned: loyaltyPointsEarned,
        loyaltyBalanceAfter: loyaltyBalanceAfter,
        loyaltyTier: projectedTier.name,
        loyaltyPointsMultiplier: _loyaltyTierRules.multiplierFor(projectedTier),
        status: OrderStatus.completed,
        completedAt: now,
        paidAt: now,
        paymentMethod: 'cash',
        amountReceived: order.amountReceived,
        amountApplied: order.totalAmount,
        paid: order.amountReceived,
        change: order.amountReceived - order.totalAmount,
        createdBy: order.createdBy.isEmpty ? actor.id : order.createdBy,
        createdByName:
            order.createdByName.isEmpty ? actor.name : order.createdByName,
        updatedBy: actor.id,
        updatedAt: now,
        stockApplied: true,
        stockRestored: false,
      );

      final updatedOrders = orderSnapshot
          .map(
            (map) => Map<String, dynamic>.from(map),
          )
          .toList();

      _upsertOrder(updatedOrders, completed);

      if (updatedOrders.length > AppConfig.maxDemoTransactions) {
        updatedOrders.removeRange(
          0,
          updatedOrders.length - AppConfig.maxDemoTransactions,
        );
      }

      await _putMaps('products', updatedProducts);
      _writeFaultInjector?.call('after_products');

      await _putMaps('transactions', updatedOrders);
      _writeFaultInjector?.call('after_order');

      if (completed.loyaltyPointsRedeemed > 0) {
        final redemptionResult = await loyaltyRepository.redeemForOrder(
          customerId: customerId,
          orderId: completed.id,
          points: completed.loyaltyPointsRedeemed,
          reason: 'Checkout loyalty discount',
        );

        if (!redemptionResult.isSuccess) {
          throw StateError(
            redemptionResult.message ?? 'Loyalty points could not be redeemed.',
          );
        }
      }

      if (customerId.isNotEmpty) {
        final loyaltyResult = await loyaltyRepository.earnForOrder(
          customerId: customerId,
          orderId: completed.id,
          eligibleAmount: completed.totalAmount,
        );

        if (!loyaltyResult.isSuccess &&
            loyaltyResult.code != 'no_loyalty_points') {
          throw StateError(
            loyaltyResult.message ?? 'Loyalty points could not be saved.',
          );
        }
      }

      _writeFaultInjector?.call('after_loyalty');

      await _notifyStockTransitions(
        productSnapshot,
        updatedProducts,
      );

      await _notify(
        type: 'transactionCompleted',
        title: 'Transaction completed',
        message: '${completed.orderId} was paid in cash.',
        entityType: 'order',
        entityId: completed.id,
        route: '/cashier/orders',
        severity: 'success',
      );

      return PosOperationResult.success(completed);
    } catch (_) {
      try {
        await _putMaps('products', productSnapshot);
        await _putMaps('transactions', orderSnapshot);
        await _putMaps(
          HiveLoyaltyProvider.storageKey,
          loyaltySnapshot,
        );

        return PosOperationResult.failure(
          'atomic_write_failed',
          'Checkout could not be saved. No stock or transaction data was changed.',
        );
      } catch (_) {
        return PosOperationResult.failure(
          'rollback_failed',
          'Checkout failed and local recovery could not be confirmed. '
              'Reset or restore local data before continuing.',
        );
      }
    } finally {
      _operationInProgress = false;
    }
  }

  @override
  Future<PosOperationResult<OrderModel>> saveOpenOrder(
    OrderModel order,
  ) async {
    final permission = order.status == OrderStatus.held
        ? AppPermission.holdOrder
        : AppPermission.saveOrder;

    if (!hasPermission(permission)) {
      return _permissionDenied(permission);
    }

    if (!OrderStatus.open.contains(order.status)) {
      return PosOperationResult.failure(
        'invalid_open_status',
        'Only held or saved orders can be stored as open orders.',
      );
    }

    if (order.items.isEmpty) {
      return PosOperationResult.failure(
        'empty_cart',
        'An open order must contain at least one item.',
      );
    }

    final values = _maps('transactions');

    if (values.any(
      (map) => map['orderId'] == order.orderId && map['id'] != order.id,
    )) {
      return PosOperationResult.failure(
        'duplicate_transaction_id',
        'Transaction ID already exists.',
      );
    }

    final existing = values
        .where(
          (map) => map['id'] == order.id,
        )
        .firstOrNull;

    if (existing != null) {
      final current = OrderModel.fromMap(
        existing['id'] as String,
        existing,
      );

      if (!OrderStatus.open.contains(current.status)) {
        return PosOperationResult.failure(
          'order_closed',
          'A completed, cancelled, or refunded order cannot be edited.',
        );
      }
    }

    final actor = _currentUser!;

    final saved = order.copyWith(
      createdBy: order.createdBy.isEmpty ? actor.id : order.createdBy,
      createdByName:
          order.createdByName.isEmpty ? actor.name : order.createdByName,
      updatedBy: actor.id,
      stockApplied: false,
      stockRestored: false,
      updatedAt: DateTime.now(),
    );

    _upsertOrder(values, saved);

    await _putMaps('transactions', values);

    await _notify(
      type: saved.status == OrderStatus.held ? 'orderHeld' : 'orderSaved',
      title: saved.status == OrderStatus.held ? 'Order held' : 'Order saved',
      message: saved.status == OrderStatus.held
          ? '${saved.orderId} is paused for this shift.'
          : '${saved.orderId} is open for later payment.',
      entityType: 'order',
      entityId: saved.id,
      route: '/cashier/orders',
    );

    return PosOperationResult.success(saved);
  }

  @override
  Future<PosOperationResult<OrderModel>> cancelOpenOrder(
    String id,
    String reason,
  ) async {
    if (!hasPermission(AppPermission.cancelOpenOrder)) {
      return _permissionDenied(
        AppPermission.cancelOpenOrder,
      );
    }

    if (reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'cancellation_reason_required',
        'Enter a reason for cancelling the open order.',
      );
    }

    final values = _maps('transactions');

    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'order_missing',
        'Order was not found.',
      );
    }

    final order = OrderModel.fromMap(
      id,
      values[index],
    );

    if (!OrderStatus.open.contains(order.status)) {
      return PosOperationResult.failure(
        'order_not_open',
        'Only held or saved orders can be cancelled.',
      );
    }

    final now = DateTime.now();

    final cancelled = order.copyWith(
      status: OrderStatus.cancelled,
      cancelledAt: now,
      cancelledBy: _currentUser!.id,
      cancellationReason: reason.trim(),
      updatedBy: _currentUser!.id,
      updatedAt: now,
    );

    values[index] = _orderMap(cancelled);

    await _putMaps('transactions', values);

    await _notify(
      type: 'orderCancelled',
      title: 'Order cancelled',
      message: '${cancelled.orderId}: ${reason.trim()}',
      entityType: 'order',
      entityId: cancelled.id,
      route: '/cashier/orders',
      severity: 'warning',
    );

    return PosOperationResult.success(cancelled);
  }

  @override
  Future<PosOperationResult<void>> deleteOpenOrder(String id) async {
    return PosOperationResult.failure(
      'permanent_delete_disabled',
      'Permanent deletion is disabled in public demo mode. '
          'Move the record to Trash instead.',
    );
  }

  @override
  Future<PosOperationResult<OrderModel>> softDeleteOrder(
    String id,
    String reason,
  ) async {
    if (!hasPermission(AppPermission.softDeleteOrder)) {
      return _permissionDenied(
        AppPermission.softDeleteOrder,
      );
    }

    if (reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'delete_reason_required',
        'Enter a reason for moving this order to Trash.',
      );
    }

    final values = _maps('transactions');

    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'order_missing',
        'Order was not found.',
      );
    }

    final order = OrderModel.fromMap(
      id,
      values[index],
    );

    if (order.isDeleted) {
      return PosOperationResult.failure(
        'already_deleted',
        'This order is already in Trash.',
      );
    }

    final now = DateTime.now();

    final deleted = order.copyWith(
      isDeleted: true,
      deletedAt: now,
      deletedBy: _currentUser!.id,
      deleteReason: reason.trim(),
      updatedBy: _currentUser!.id,
      updatedAt: now,
    );

    values[index] = _orderMap(deleted);

    await _putMaps('transactions', values);

    await _notify(
      type: 'recordSoftDeleted',
      title: 'Order moved to Trash',
      message: '${deleted.orderId}: ${reason.trim()}',
      entityType: 'order',
      entityId: deleted.id,
      route: '/cashier/trash',
      severity: 'warning',
    );

    return PosOperationResult.success(deleted);
  }

  @override
  Future<PosOperationResult<OrderModel>> restoreOrder(
    String id,
  ) async {
    if (!hasPermission(AppPermission.restoreOrder)) {
      return _permissionDenied(
        AppPermission.restoreOrder,
      );
    }

    final values = _maps('transactions');

    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'order_missing',
        'Order was not found.',
      );
    }

    final order = OrderModel.fromMap(
      id,
      values[index],
    );

    if (!order.isDeleted) {
      return PosOperationResult.failure(
        'order_not_deleted',
        'This order is not in Trash.',
      );
    }

    final now = DateTime.now();

    final restored = order.copyWith(
      isDeleted: false,
      clearDeletion: true,
      restoredAt: now,
      restoredBy: _currentUser!.id,
      updatedBy: _currentUser!.id,
      updatedAt: now,
    );

    values[index] = _orderMap(restored);

    await _putMaps('transactions', values);

    await _notify(
      type: 'recordRestored',
      title: 'Order restored',
      message: '${restored.orderId} returned to active orders.',
      entityType: 'order',
      entityId: restored.id,
      route: '/cashier/orders',
      severity: 'success',
    );

    return PosOperationResult.success(restored);
  }

  @override
  Future<PosOperationResult<OrderModel>> refundSale(
    String id,
    String reason, {
    bool restoreStock = true,
  }) async {
    if (!hasPermission(AppPermission.refundCompletedOrder)) {
      return _permissionDenied(
        AppPermission.refundCompletedOrder,
      );
    }

    if (reason.trim().isEmpty) {
      return PosOperationResult.failure(
        'refund_reason_required',
        'Enter a reason for the refund.',
      );
    }

    if (_operationInProgress) {
      return PosOperationResult.failure(
        'operation_busy',
        'Another stock operation is still being processed.',
      );
    }

    _operationInProgress = true;

    final productSnapshot = _maps('products');
    final orderSnapshot = _maps('transactions');
    final loyaltySnapshot = _maps(HiveLoyaltyProvider.storageKey);

    try {
      final index = orderSnapshot.indexWhere(
        (map) => map['id'] == id,
      );

      if (index < 0) {
        return PosOperationResult.failure(
          'order_missing',
          'Transaction was not found.',
        );
      }

      final order = OrderModel.fromMap(
        id,
        orderSnapshot[index],
      );

      if (order.status == OrderStatus.refunded || order.stockRestored) {
        return PosOperationResult.failure(
          'already_refunded',
          'This transaction has already been refunded.',
        );
      }

      if (order.status != OrderStatus.completed || !order.stockApplied) {
        return PosOperationResult.failure(
          'refund_not_allowed',
          'Only completed transactions can be refunded.',
        );
      }

      final updatedProducts = productSnapshot
          .map(
            (map) => Map<String, dynamic>.from(map),
          )
          .toList();

      if (restoreStock) {
        final quantities = <String, int>{};

        for (final item in order.items) {
          quantities[item.id] = (quantities[item.id] ?? 0) + item.quantity;
        }

        for (final entry in quantities.entries) {
          final productIndex = updatedProducts.indexWhere(
            (map) => map['id'] == entry.key,
          );

          if (productIndex < 0) {
            return PosOperationResult.failure(
              'product_missing',
              'A refunded product no longer exists. '
                  'Restore it before refunding.',
            );
          }

          final stock =
              (updatedProducts[productIndex]['stock'] as num?)?.toInt() ?? 0;

          updatedProducts[productIndex]['stock'] = stock + entry.value;
        }
      }

      final now = DateTime.now();

      final refunded = order.copyWith(
        status: OrderStatus.refunded,
        refundedAt: now,
        refundReason: reason.trim(),
        refundedBy: _currentUser!.id,
        updatedBy: _currentUser!.id,
        stockRestored: restoreStock,
        updatedAt: now,
      );

      final updatedOrders = orderSnapshot
          .map(
            (map) => Map<String, dynamic>.from(map),
          )
          .toList();

      updatedOrders[index] = _orderMap(refunded);

      await _putMaps('products', updatedProducts);
      _writeFaultInjector?.call('after_refund_products');

      await _putMaps('transactions', updatedOrders);
      _writeFaultInjector?.call('after_refund_order');

      final customerId = refunded.customerId?.trim() ?? '';

      if (customerId.isNotEmpty) {
        final loyaltyResult = await loyaltyRepository.reverseOrderEarning(
          orderId: refunded.id,
          reason: 'Refund: ${reason.trim()}',
        );

        if (!loyaltyResult.isSuccess &&
            loyaltyResult.code != 'loyalty_earning_missing') {
          throw StateError(
            loyaltyResult.message ?? 'Loyalty points could not be reversed.',
          );
        }
      }

      if (refunded.loyaltyPointsRedeemed > 0) {
        final restorationResult =
            await loyaltyRepository.restoreOrderRedemption(
          orderId: refunded.id,
          reason: 'Refund: ${reason.trim()}',
        );

        if (!restorationResult.isSuccess) {
          throw StateError(
            restorationResult.message ??
                'Redeemed loyalty points could not be restored.',
          );
        }
      }

      _writeFaultInjector?.call('after_refund_loyalty');

      await _notify(
        type: 'transactionRefunded',
        title: 'Transaction refunded',
        message: '${refunded.orderId}: ${reason.trim()}',
        entityType: 'order',
        entityId: refunded.id,
        route: '/cashier/orders',
        severity: 'warning',
      );

      return PosOperationResult.success(refunded);
    } catch (_) {
      try {
        await _putMaps('products', productSnapshot);
        await _putMaps('transactions', orderSnapshot);
        await _putMaps(
          HiveLoyaltyProvider.storageKey,
          loyaltySnapshot,
        );

        return PosOperationResult.failure(
          'atomic_write_failed',
          'Refund could not be saved. '
              'No stock or transaction data was changed.',
        );
      } catch (_) {
        return PosOperationResult.failure(
          'rollback_failed',
          'Refund failed and local recovery could not be confirmed. '
              'Reset or restore local data before continuing.',
        );
      }
    } finally {
      _operationInProgress = false;
    }
  }

  @override
  Future<PosOperationResult<OrderModel>> updateReceiptStatus(
    String id,
    String receiptStatus,
  ) async {
    if (!{
      ReceiptState.pending,
      ReceiptState.printed,
      ReceiptState.emailed,
      ReceiptState.failed,
    }.contains(receiptStatus)) {
      return PosOperationResult.failure(
        'invalid_receipt_status',
        'Receipt status is invalid.',
      );
    }

    final values = _maps('transactions');

    final index = values.indexWhere(
      (map) => map['id'] == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'order_missing',
        'Transaction was not found.',
      );
    }

    final order = OrderModel.fromMap(
      id,
      values[index],
    );

    final updated = order.copyWith(
      receiptStatus: receiptStatus,
      updatedAt: DateTime.now(),
    );

    values[index] = _orderMap(updated);

    await _putMaps('transactions', values);

    return PosOperationResult.success(updated);
  }

  @override
  Future<void> saveTransaction(OrderModel order) async {
    final result = order.status == OrderStatus.completed
        ? await completeSale(
            order.copyWith(
              status: OrderStatus.draft,
            ),
          )
        : await saveOpenOrder(order);

    if (!result.isSuccess) {
      throw PosOperationException(
        result.code!,
        result.message!,
      );
    }
  }

  @override
  Future<List<CustomerModel>> getCustomers({
    bool includeDeleted = false,
  }) async {
    final customers = _maps('customers')
        .map(_customerFromMap)
        .where(
          (customer) => includeDeleted || !customer.isDeleted,
        )
        .toList();

    customers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return customers;
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    final map = _maps('customers')
        .where(
          (item) => _customerMapId(item) == id,
        )
        .firstOrNull;

    return map == null ? null : _customerFromMap(map);
  }

  @override
  Future<CustomerModel> createCustomer(
    CustomerModel customer,
  ) async {
    _requirePermission(AppPermission.manageCustomers);

    final values = _maps('customers');

    _validateCustomer(
      customer,
      values,
      isCreating: true,
    );

    final sequence = await _nextCustomerSequence();
    final now = DateTime.now();

    final created = CustomerModel(
      id: customer.id.trim().isEmpty
          ? 'customer-${now.microsecondsSinceEpoch}'
          : customer.id.trim(),
      membershipId: customer.membershipId.trim().isEmpty
          ? CustomerUtils.generateMembershipId(sequence)
          : customer.membershipId.trim().toUpperCase(),
      name: customer.name.trim(),
      phone: customer.phone.trim(),
      normalizedPhone: CustomerUtils.normalizePhone(
        customer.phone,
      ),
      whatsapp: customer.whatsapp.trim(),
      normalizedWhatsapp: CustomerUtils.normalizePhone(
        customer.whatsapp,
      ),
      email: customer.email.trim().toLowerCase(),
      address: customer.address.trim(),
      notes: customer.notes.trim(),
      createdAt: customer.createdAt ?? now,
      updatedAt: now,
    );

    final duplicateMembership = values.any(
      (map) =>
          map['membershipId']?.toString().toUpperCase() ==
          created.membershipId.toUpperCase(),
    );

    if (duplicateMembership) {
      throw const FormatException(
        'Membership ID already exists.',
      );
    }

    values.add(created.toMap());

    await _putMaps('customers', values);

    await _notify(
      type: 'customerCreated',
      title: 'Customer created',
      message: '${created.name} (${created.membershipId})',
      entityType: 'customer',
      entityId: created.id,
      route: '/cashier/customers',
      severity: 'success',
    );

    return created;
  }

  @override
  Future<CustomerModel> updateCustomer(
    CustomerModel customer,
  ) async {
    _requirePermission(AppPermission.manageCustomers);

    final values = _maps('customers');

    final index = values.indexWhere(
      (map) => _customerMapId(map) == customer.id,
    );

    if (index < 0) {
      throw StateError(
        'Customer was not found.',
      );
    }

    _validateCustomer(
      customer,
      values,
      isCreating: false,
    );

    final existing = _customerFromMap(
      values[index],
    );

    final updated = CustomerModel(
      id: existing.id,
      membershipId: existing.membershipId,
      name: customer.name.trim(),
      phone: customer.phone.trim(),
      normalizedPhone: CustomerUtils.normalizePhone(
        customer.phone,
      ),
      whatsapp: customer.whatsapp.trim(),
      normalizedWhatsapp: CustomerUtils.normalizePhone(
        customer.whatsapp,
      ),
      email: customer.email.trim().toLowerCase(),
      address: customer.address.trim(),
      notes: customer.notes.trim(),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      isDeleted: existing.isDeleted,
      deletedAt: existing.deletedAt,
      deletedBy: existing.deletedBy,
      restoredAt: existing.restoredAt,
      restoredBy: existing.restoredBy,
    );

    values[index] = updated.toMap();

    await _putMaps('customers', values);

    await _notify(
      type: 'customerUpdated',
      title: 'Customer updated',
      message: updated.name,
      entityType: 'customer',
      entityId: updated.id,
      route: '/cashier/customers',
    );

    return updated;
  }

  @override
  Future<PosOperationResult<CustomerModel>> deleteCustomer(
    String id, {
    String deletedBy = '',
  }) async {
    if (!hasPermission(AppPermission.manageCustomers)) {
      return _permissionDenied(
        AppPermission.manageCustomers,
      );
    }

    final values = _maps('customers');

    final index = values.indexWhere(
      (map) => _customerMapId(map) == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'customer_missing',
        'Customer was not found.',
      );
    }

    final customer = _customerFromMap(
      values[index],
    );

    if (customer.isDeleted) {
      return PosOperationResult.failure(
        'already_deleted',
        'Customer is already in Trash.',
      );
    }

    final now = DateTime.now();

    final deleted = CustomerModel(
      id: customer.id,
      membershipId: customer.membershipId,
      name: customer.name,
      phone: customer.phone,
      normalizedPhone: customer.normalizedPhone,
      whatsapp: customer.whatsapp,
      normalizedWhatsapp: customer.normalizedWhatsapp,
      email: customer.email,
      address: customer.address,
      notes: customer.notes,
      createdAt: customer.createdAt,
      updatedAt: now,
      isDeleted: true,
      deletedAt: now,
      deletedBy: deletedBy.trim().isNotEmpty
          ? deletedBy.trim()
          : _currentUser?.id ?? '',
      restoredAt: customer.restoredAt,
      restoredBy: customer.restoredBy,
    );

    values[index] = deleted.toMap();

    await _putMaps('customers', values);

    await _notify(
      type: 'customerDeleted',
      title: 'Customer moved to Trash',
      message: deleted.name,
      entityType: 'customer',
      entityId: deleted.id,
      route: '/cashier/customers',
      severity: 'warning',
    );

    return PosOperationResult.success(deleted);
  }

  @override
  Future<PosOperationResult<CustomerModel>> restoreCustomer(
    String id, {
    String restoredBy = '',
  }) async {
    if (!hasPermission(AppPermission.manageCustomers)) {
      return _permissionDenied(
        AppPermission.manageCustomers,
      );
    }

    final values = _maps('customers');

    final index = values.indexWhere(
      (map) => _customerMapId(map) == id,
    );

    if (index < 0) {
      return PosOperationResult.failure(
        'customer_missing',
        'Customer was not found.',
      );
    }

    final customer = _customerFromMap(
      values[index],
    );

    if (!customer.isDeleted) {
      return PosOperationResult.failure(
        'customer_not_deleted',
        'Customer is not in Trash.',
      );
    }

    final now = DateTime.now();

    final restored = CustomerModel(
      id: customer.id,
      membershipId: customer.membershipId,
      name: customer.name,
      phone: customer.phone,
      normalizedPhone: customer.normalizedPhone,
      whatsapp: customer.whatsapp,
      normalizedWhatsapp: customer.normalizedWhatsapp,
      email: customer.email,
      address: customer.address,
      notes: customer.notes,
      createdAt: customer.createdAt,
      updatedAt: now,
      isDeleted: false,
      deletedAt: null,
      deletedBy: '',
      restoredAt: now,
      restoredBy: restoredBy.trim().isNotEmpty
          ? restoredBy.trim()
          : _currentUser?.id ?? '',
    );

    values[index] = restored.toMap();

    await _putMaps('customers', values);

    await _notify(
      type: 'customerRestored',
      title: 'Customer restored',
      message: restored.name,
      entityType: 'customer',
      entityId: restored.id,
      route: '/cashier/customers',
      severity: 'success',
    );

    return PosOperationResult.success(restored);
  }

  @override
  Future<List<CustomerModel>> searchCustomers(
    String query, {
    bool includeDeleted = false,
  }) async {
    final textQuery = query.trim().toLowerCase();
    final phoneQuery = CustomerUtils.normalizePhone(query);

    final customers = await getCustomers(
      includeDeleted: includeDeleted,
    );

    if (textQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final matchesName = customer.name.toLowerCase().contains(textQuery);

      final matchesMembership =
          customer.membershipId.toLowerCase().contains(textQuery);

      final matchesPhone = phoneQuery.isNotEmpty &&
          customer.normalizedPhone.contains(phoneQuery);

      final matchesWhatsapp = phoneQuery.isNotEmpty &&
          customer.normalizedWhatsapp.contains(phoneQuery);

      return matchesName ||
          matchesMembership ||
          matchesPhone ||
          matchesWhatsapp;
    }).toList();
  }

  @override
  Future<CustomerModel?> findCustomerByPhone(
    String phone,
  ) async {
    final normalizedPhone = CustomerUtils.normalizePhone(phone);

    if (normalizedPhone.isEmpty) {
      return null;
    }

    return _maps('customers')
        .map(_customerFromMap)
        .where(
          (customer) =>
              !customer.isDeleted &&
              customer.normalizedPhone == normalizedPhone,
        )
        .firstOrNull;
  }

  @override
  Future<CustomerModel?> findCustomerByMembershipId(
    String membershipId,
  ) async {
    final normalizedId = membershipId.trim().toUpperCase();

    if (normalizedId.isEmpty) {
      return null;
    }

    return _maps('customers')
        .map(_customerFromMap)
        .where(
          (customer) =>
              !customer.isDeleted &&
              customer.membershipId.toUpperCase() == normalizedId,
        )
        .firstOrNull;
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    return _maps('expenses').map(ExpenseModel.fromMap).toList()
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
  }

  @override
  Future<void> saveExpense(
    ExpenseModel expense,
  ) async {
    _requirePermission(AppPermission.manageExpenses);

    final values = _maps('expenses');

    final index = values.indexWhere(
      (map) => map['id'] == expense.id,
    );

    if (index < 0) {
      values.add(expense.toMap());
    } else {
      values[index] = expense.toMap();
    }

    await _putMaps('expenses', values);

    await _notify(
      type: 'expenseCreated',
      title: 'Expense saved',
      message: expense.title,
      entityType: 'expense',
      entityId: expense.id,
      route: '/cashier/expenses',
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    _requirePermission(AppPermission.manageExpenses);

    await _putMaps(
      'expenses',
      _maps('expenses')
        ..removeWhere(
          (map) => map['id'] == id,
        ),
    );
  }

  @override
  Future<void> resetDemoData() async {
    await _box.clear();

    _currentUser = null;

    await _box.put(
      'seedVersion',
      currentSchemaVersion,
    );

    await _seedDemoUsers();

    final now = DateTime.now();

    await _putMaps('notifications', [
      LocalNotificationModel(
        id: 'notification-seed-1',
        type: 'lowStock',
        title: 'Low stock detected',
        message: 'Rice 5kg has only 2 items left.',
        entityType: 'product',
        entityId: 'rice',
        route: '/cashier/inventory',
        createdAt: now.subtract(
          const Duration(minutes: 15),
        ),
        isRead: false,
        actorId: 'system',
        actorName: 'Local Inventory',
        severity: 'warning',
      ).toMap(),
      LocalNotificationModel(
        id: 'notification-seed-2',
        type: 'transactionCompleted',
        title: 'Transaction completed',
        message: 'DEMO-1001 was paid in cash.',
        entityType: 'order',
        entityId: 'seed-1',
        route: '/cashier/orders',
        createdAt: now.subtract(
          const Duration(hours: 1),
        ),
        isRead: false,
        actorId: 'demo-staff',
        actorName: 'Demo Staff',
        severity: 'success',
      ).toMap(),
      LocalNotificationModel(
        id: 'notification-seed-3',
        type: 'orderSaved',
        title: 'Order saved',
        message: 'DEMO-OPEN is ready for later payment.',
        entityType: 'order',
        entityId: 'seed-saved',
        route: '/cashier/orders',
        createdAt: now.subtract(
          const Duration(hours: 2),
        ),
        isRead: true,
        readAt: now.subtract(
          const Duration(hours: 1),
        ),
        actorId: 'demo-owner',
        actorName: 'Demo Owner',
        severity: 'info',
      ).toMap(),
    ]);

    await _putMaps('categories', const [
      {
        'id': 'cat-drinks',
        'name': 'Beverages',
        'iconName': 'beverages',
      },
      {
        'id': 'cat-snacks',
        'name': 'Snacks',
        'iconName': 'snacks',
      },
      {
        'id': 'cat-grocery',
        'name': 'Grocery',
        'iconName': 'grocery',
      },
      {
        'id': 'cat-care',
        'name': 'Personal Care',
        'iconName': 'personalCare',
      },
      {
        'id': 'cat-household',
        'name': 'Household',
        'iconName': 'household',
      },
      {
        'id': 'cat-others',
        'name': 'Others',
        'iconName': 'other',
      },
    ]);

    await _putMaps('products', const [
      {
        'id': 'water',
        'name': 'Water Bottle 500ml',
        'categoryId': 'cat-drinks',
        'categoryName': 'Beverages',
        'variants': [
          {
            'size': 'Regular',
            'price': 7500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'WTR500',
        'stock': 38,
        'lowStockThreshold': 5,
      },
      {
        'id': 'cola',
        'name': 'Cola 330ml',
        'categoryId': 'cat-drinks',
        'categoryName': 'Beverages',
        'variants': [
          {
            'size': 'Regular',
            'price': 12500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'CC330',
        'stock': 45,
        'lowStockThreshold': 5,
      },
      {
        'id': 'chips',
        'name': 'Classic Chips 52g',
        'categoryId': 'cat-snacks',
        'categoryName': 'Snacks',
        'variants': [
          {
            'size': 'Regular',
            'price': 15000.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'LAY52',
        'stock': 35,
        'lowStockThreshold': 5,
      },
      {
        'id': 'rice',
        'name': 'Rice 5kg',
        'categoryId': 'cat-grocery',
        'categoryName': 'Grocery',
        'variants': [
          {
            'size': '5 kg',
            'price': 69000.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'RICE5KG',
        'stock': 2,
        'lowStockThreshold': 5,
      },
      {
        'id': 'pringles',
        'name': 'Pringles Original 110g',
        'categoryId': 'cat-snacks',
        'categoryName': 'Snacks',
        'variants': [
          {
            'size': 'Regular',
            'price': 27500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'PRG110',
        'stock': 22,
        'lowStockThreshold': 5,
      },
      {
        'id': 'snickers',
        'name': 'Snickers 50g',
        'categoryId': 'cat-snacks',
        'categoryName': 'Snacks',
        'variants': [
          {
            'size': 'Regular',
            'price': 17500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'SNK50',
        'stock': 28,
        'lowStockThreshold': 5,
      },
      {
        'id': 'shampoo',
        'name': 'Shampoo 400ml',
        'categoryId': 'cat-care',
        'categoryName': 'Personal Care',
        'variants': [
          {
            'size': 'Regular',
            'price': 32500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'SHP400',
        'stock': 18,
        'lowStockThreshold': 5,
      },
      {
        'id': 'toothpaste',
        'name': 'Toothpaste 100ml',
        'categoryId': 'cat-care',
        'categoryName': 'Personal Care',
        'variants': [
          {
            'size': 'Regular',
            'price': 18000.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'TTP100',
        'stock': 14,
        'lowStockThreshold': 5,
      },
      {
        'id': 'detergent',
        'name': 'Detergent 1kg',
        'categoryId': 'cat-household',
        'categoryName': 'Household',
        'variants': [
          {
            'size': '1 kg',
            'price': 45000.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'DTR1KG',
        'stock': 5,
        'lowStockThreshold': 5,
      },
      {
        'id': 'oil',
        'name': 'Cooking Oil 1L',
        'categoryId': 'cat-grocery',
        'categoryName': 'Grocery',
        'variants': [
          {
            'size': '1 L',
            'price': 29500.0,
          },
        ],
        'description': '',
        'imageBase64': '',
        'imageMimeType': '',
        'imageName': '',
        'sku': 'OIL1L',
        'stock': 0,
        'lowStockThreshold': 5,
      },
    ]);

    await _box.put(
      _customerSequenceKey,
      1,
    );

    await _putMaps('customers', [
      CustomerModel(
        id: 'customer-1',
        membershipId: 'MBR-000001',
        name: 'Maya Customer',
        phone: '081234567890',
        normalizedPhone: '6281234567890',
        whatsapp: '081234567890',
        normalizedWhatsapp: '6281234567890',
        email: 'maya@demo.local',
        address: 'Demo Customer Address',
        notes: 'Demo member customer.',
        createdAt: now,
        updatedAt: now,
      ).toMap(),
    ]);

    await HiveLoyaltyProvider(_box).clear();

    await _putMaps('expenses', [
      ExpenseModel(
        id: 'expense-1',
        title: 'Store supplies',
        amount: 85000,
        category: 'Operations',
        createdAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
      ).toMap(),
    ]);

    final seeded = OrderModel(
      id: 'seed-1',
      orderId: 'DEMO-1001',
      items: [
        CartItemModel(
          id: 'cola',
          name: 'Cola 330ml',
          size: 'Regular',
          price: 12500,
          quantity: 2,
        ),
      ],
      totalAmount: 25000,
      discount: 0,
      paid: 30000,
      change: 5000,
      createdAt: DateTime.now().subtract(
        const Duration(hours: 1),
      ),
      createdBy: 'demo-admin',
    );

    final orders = <OrderModel>[
      seeded,
      OrderModel(
        id: 'seed-2',
        orderId: 'DEMO-1002',
        items: [
          CartItemModel(
            id: 'water',
            name: 'Water Bottle 500ml',
            size: 'Regular',
            price: 7500,
            quantity: 3,
          ),
        ],
        totalAmount: 22500,
        discount: 0,
        paid: 25000,
        change: 2500,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 2),
        ),
        createdBy: 'demo-admin',
        receiptStatus: ReceiptState.emailed,
      ),
      OrderModel(
        id: 'seed-3',
        orderId: 'DEMO-1003',
        items: [
          CartItemModel(
            id: 'chips',
            name: 'Classic Chips 52g',
            size: 'Regular',
            price: 15000,
            quantity: 2,
          ),
        ],
        totalAmount: 27000,
        discount: 3000,
        paid: 30000,
        change: 3000,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 3),
        ),
        createdBy: 'demo-admin',
      ),
      OrderModel(
        id: 'seed-4',
        orderId: 'DEMO-1004',
        items: [
          CartItemModel(
            id: 'snickers',
            name: 'Snickers 50g',
            size: 'Regular',
            price: 17500,
            quantity: 2,
          ),
        ],
        totalAmount: 35000,
        discount: 0,
        paid: 35000,
        change: 0,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 4),
        ),
        createdBy: 'demo-admin',
        status: OrderStatus.cancelled,
        receiptStatus: ReceiptState.failed,
      ),
      OrderModel(
        id: 'seed-5',
        orderId: 'DEMO-1005',
        items: [
          CartItemModel(
            id: 'pringles',
            name: 'Pringles Original 110g',
            size: 'Regular',
            price: 27500,
            quantity: 1,
          ),
        ],
        totalAmount: 27500,
        discount: 0,
        paid: 30000,
        change: 2500,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 5),
        ),
        createdBy: 'demo-admin',
      ),
      OrderModel(
        id: 'seed-6',
        orderId: 'DEMO-1006',
        items: [
          CartItemModel(
            id: 'snickers',
            name: 'Snickers 50g',
            size: 'Regular',
            price: 17500,
            quantity: 2,
          ),
        ],
        totalAmount: 35000,
        discount: 0,
        paid: 35000,
        change: 0,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 6),
        ),
        createdBy: 'demo-admin',
      ),
      OrderModel(
        id: 'seed-held',
        orderId: 'DEMO-HELD',
        items: [
          CartItemModel(
            id: 'water',
            name: 'Water Bottle 500ml',
            size: 'Regular',
            price: 7500,
            quantity: 1,
          ),
        ],
        totalAmount: 8250,
        discount: 0,
        taxType: TaxType.percentage,
        taxValue: 10,
        taxAmount: 750,
        paid: 0,
        amountReceived: 0,
        amountApplied: 0,
        change: 0,
        createdAt: DateTime.now().subtract(
          const Duration(minutes: 45),
        ),
        createdBy: 'demo-staff',
        createdByName: 'Demo Staff',
        status: OrderStatus.held,
        receiptStatus: ReceiptState.pending,
      ),
      OrderModel(
        id: 'seed-saved',
        orderId: 'DEMO-OPEN',
        items: [
          CartItemModel(
            id: 'chips',
            name: 'Classic Chips 52g',
            size: 'Regular',
            price: 15000,
            quantity: 1,
          ),
        ],
        totalAmount: 16500,
        discount: 0,
        taxType: TaxType.percentage,
        taxValue: 10,
        taxAmount: 1500,
        paid: 0,
        amountReceived: 0,
        amountApplied: 0,
        change: 0,
        customerId: 'customer-1',
        customerName: 'Maya Customer',
        notes: 'Customer will collect after 5 PM.',
        createdAt: DateTime.now().subtract(
          const Duration(hours: 2),
        ),
        createdBy: 'demo-owner',
        createdByName: 'Demo Owner',
        status: OrderStatus.saved,
        receiptStatus: ReceiptState.pending,
      ),
      OrderModel(
        id: 'seed-trash',
        orderId: 'DEMO-TRASH',
        items: [
          CartItemModel(
            id: 'water',
            name: 'Water Bottle 500ml',
            size: 'Regular',
            price: 7500,
            quantity: 1,
          ),
        ],
        totalAmount: 7500,
        discount: 0,
        paid: 0,
        amountReceived: 0,
        amountApplied: 0,
        change: 0,
        createdAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
        createdBy: 'demo-owner',
        createdByName: 'Demo Owner',
        status: OrderStatus.cancelled,
        cancelledAt: DateTime.now().subtract(
          const Duration(days: 1),
        ),
        cancelledBy: 'demo-owner',
        cancellationReason: 'Duplicate open order',
        isDeleted: true,
        deletedAt: DateTime.now().subtract(
          const Duration(hours: 20),
        ),
        deletedBy: 'demo-owner',
        deleteReason: 'Archived duplicate order',
        receiptStatus: ReceiptState.pending,
      ),
    ];

    await _putMaps(
      'transactions',
      orders.map(
        (order) => {
          'id': order.id,
          ...order.toMap(),
          'createdAt': order.createdAt.toIso8601String(),
        },
      ),
    );
  }
}
