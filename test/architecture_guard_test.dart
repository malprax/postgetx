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
      ];

      final violations = <String>[];
      for (final rootPath in const ['lib', 'test']) {
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
