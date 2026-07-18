import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = Directory.current;

  group('architecture guard', () {
    test('migrated sources exist only in their canonical app paths', () {
      const migrations = <String, String>{
        'lib/models/customer_model.dart':
            'lib/app/data/models/customer_model.dart',
        'lib/utils/customer_utils.dart':
            'lib/app/core/helpers/customer_utils.dart',
        'lib/repositories/customer_repository.dart':
            'lib/app/data/repositories/customer_repository.dart',
        'lib/modules/customers/widgets/customer_form.dart':
            'lib/app/modules/customers/widgets/customer_form.dart',
        'lib/models/menu_item_model.dart':
            'lib/app/data/models/menu_item_model.dart',
        'lib/models/menu_variant.dart': 'lib/app/data/models/menu_variant.dart',
        'lib/services/product_image_service.dart':
            'lib/app/core/services/product_image_service.dart',
        'lib/modules/menu': 'lib/app/modules/menu',
        'lib/models/category_model.dart':
            'lib/app/data/models/category_model.dart',
        'lib/modules/category': 'lib/app/modules/category',
        'lib/bindings/category_binding.dart':
            'lib/app/modules/category/bindings',
        'lib/modules/pos': 'lib/app/modules/pos',
        'lib/bindings/pos_binding.dart':
            'lib/app/modules/pos/bindings/pos_binding.dart',
        'lib/models/cart_item_model.dart':
            'lib/app/data/models/cart_item_model.dart',
        'lib/services/receipt_data.dart':
            'lib/app/data/models/receipt_data.dart',
        'lib/services/pos_total_calculator.dart':
            'lib/app/core/services/pos_total_calculator.dart',
        'lib/models/order_model.dart': 'lib/app/data/models/order_model.dart',
        'lib/models/order_lifecycle.dart':
            'lib/app/data/models/order_lifecycle.dart',
        'lib/services/print_service.dart':
            'lib/app/core/services/print_service.dart',
        'lib/services/printer_service.dart':
            'lib/app/core/services/printer_service.dart',
        'lib/modules/orders': 'lib/app/modules/orders',
        'lib/modules/stock': 'lib/app/modules/stock',
        'lib/bindings/stock_binding.dart': 'lib/app/modules/stock/bindings',
        'lib/services/stock_service.dart': 'lib/app/modules/stock',
        'lib/modules/tracking': 'lib/app/modules/tracking',
        'lib/bindings/tracking_binding.dart':
            'lib/app/modules/tracking/bindings',
        'lib/bindings/tracking_log_binding.dart':
            'lib/app/modules/tracking/bindings',
        'lib/models/user_model.dart': 'lib/app/data/models/user_model.dart',
        'lib/models/role_permission.dart':
            'lib/app/data/models/role_permission.dart',
        'lib/modules/users': 'lib/app/modules/users',
        'lib/bindings/users_binding.dart': 'lib/app/modules/users/bindings',
        'lib/modules/auth': 'lib/app/modules/auth',
        'lib/repositories/auth_repository.dart':
            'lib/app/data/repositories/auth_repository.dart',
        'lib/modules/dashboard': 'lib/app/modules/dashboard',
        'lib/modules/profile': 'lib/app/modules/profile',
        'lib/modules/settings': 'lib/app/modules/settings',
        'lib/themes/theme_controller.dart':
            'lib/app/modules/settings/controllers/theme_controller.dart',
        'lib/themes/app_theme.dart': 'lib/app/theme/app_theme.dart',
        'lib/widgets': 'lib/app/shared/widgets',
        'lib/config': 'lib/app/core/config',
        'lib/utils': 'lib/app/core',
        'lib/services/order_service.dart': 'lib/app/core/services',
        'lib/models': 'lib/app/data/models',
        'lib/repositories': 'lib/app/data/repositories',
        'lib/routes': 'lib/app/routes',
        'lib/bindings': 'lib/app/bindings',
      };

      for (final migration in migrations.entries) {
        expect(
          _entityExists(projectRoot, migration.value),
          isTrue,
          reason: 'Canonical source is missing: ${migration.value}',
        );
        expect(
          _entityExists(projectRoot, migration.key),
          isFalse,
          reason: 'Legacy source must not return: ${migration.key}',
        );
      }
    });

    test('Dart sources do not import migrated legacy package paths', () {
      const forbiddenImports = <String>[
        'package:postgetx/models/customer_model.dart',
        'package:postgetx/utils/customer_utils.dart',
        'package:postgetx/repositories/customer_repository.dart',
        'package:postgetx/modules/customers/widgets/customer_form.dart',
        'package:postgetx/models/menu_item_model.dart',
        'package:postgetx/models/menu_variant.dart',
        'package:postgetx/services/product_image_service.dart',
        'package:postgetx/modules/menu/',
        'package:postgetx/models/category_model.dart',
        'package:postgetx/modules/category/',
        'package:postgetx/bindings/category_binding.dart',
        'package:postgetx/modules/pos/',
        'package:postgetx/bindings/pos_binding.dart',
        'package:postgetx/models/cart_item_model.dart',
        'package:postgetx/services/receipt_data.dart',
        'package:postgetx/services/pos_total_calculator.dart',
        'package:postgetx/models/order_model.dart',
        'package:postgetx/models/order_lifecycle.dart',
        'package:postgetx/services/print_service.dart',
        'package:postgetx/services/printer_service.dart',
        'package:postgetx/modules/orders/',
        'package:postgetx/modules/stock/',
        'package:postgetx/bindings/stock_binding.dart',
        'package:postgetx/services/stock_service.dart',
        'package:postgetx/modules/tracking/',
        'package:postgetx/bindings/tracking_binding.dart',
        'package:postgetx/bindings/tracking_log_binding.dart',
        'package:postgetx/models/user_model.dart',
        'package:postgetx/models/role_permission.dart',
        'package:postgetx/modules/users/',
        'package:postgetx/bindings/users_binding.dart',
        'package:postgetx/modules/auth/',
        'package:postgetx/repositories/auth_repository.dart',
        'package:postgetx/modules/dashboard/',
        'package:postgetx/modules/profile/',
        'package:postgetx/modules/settings/',
        'package:postgetx/themes/theme_controller.dart',
        'package:postgetx/themes/app_theme.dart',
        'package:postgetx/widgets/',
        'package:postgetx/config/',
        'package:postgetx/utils/',
        'package:postgetx/services/order_service.dart',
        'package:postgetx/models/',
        'package:postgetx/repositories/',
        'package:postgetx/routes/',
        'package:postgetx/bindings/',
      ];

      final violations = <String>[];
      for (final rootPath in const ['lib', 'test', 'tools']) {
        final root = Directory('${projectRoot.path}/$rootPath');
        if (!root.existsSync()) continue;

        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          if (entity.path.endsWith('test/architecture_guard_test.dart')) {
            continue;
          }
          final source = entity.readAsStringSync();
          for (final forbiddenImport in forbiddenImports) {
            if (source.contains(forbiddenImport)) {
              violations.add(
                '${_relativePath(projectRoot, entity)} -> $forbiddenImport',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Migrate these legacy imports:\n${violations.join('\n')}',
      );
    });

    test('migration backups and migration scripts stay outside the project',
        () {
      final violations = projectRoot
          .listSync()
          .where((entity) {
            final name = entity.uri.pathSegments
                .where((segment) => segment.isNotEmpty)
                .last;
            return name == 'migration_backup' ||
                name.endsWith('_migration.sh') ||
                name.startsWith('migrate_');
          })
          .map((entity) => _relativePath(projectRoot, entity))
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'Temporary migration artifacts must stay outside the project.',
      );
    });
  });
}

bool _entityExists(Directory root, String relativePath) {
  final type = FileSystemEntity.typeSync('${root.path}/$relativePath');
  return type != FileSystemEntityType.notFound;
}

String _relativePath(Directory root, FileSystemEntity entity) {
  return entity.path.replaceFirst('${root.path}/', '');
}
