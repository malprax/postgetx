import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/providers/local/loyalty_configuration_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';
import 'package:postgetx/app/modules/settings/controllers/loyalty_configuration_controller.dart';

void main() {
  group('Feature: Only an owner controls loyalty configuration', () {
    late Directory directory;
    late Box<dynamic> repositoryBox;
    late Box<dynamic> preferenceBox;
    late LocalHiveRepository repository;
    late LoyaltyConfigurationProvider provider;
    late LoyaltyConfigurationController controller;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'loyalty-configuration-controller-',
      );

      Hive.init(directory.path);

      repositoryBox = await Hive.openBox<dynamic>(
        'repository-${DateTime.now().microsecondsSinceEpoch}',
      );

      preferenceBox = await Hive.openBox<dynamic>(
        'preferences-${DateTime.now().microsecondsSinceEpoch}',
      );

      repository = LocalHiveRepository.forBox(repositoryBox);
      await repository.resetDemoData();

      provider = LoyaltyConfigurationProvider(preferenceBox);
      controller = LoyaltyConfigurationController(
        provider,
        repository,
      );
    });

    tearDown(() async {
      await repositoryBox.close();
      await preferenceBox.close();
      await directory.delete(recursive: true);
    });

    test(
      'Given saved offline rules exist, '
      'When the application loads configuration, '
      'Then repository calculations receive the restored rules',
      () async {
        // Given:
        final saved = LoyaltyConfiguration.defaults.copyWith(
          spendPerPoint: 25000,
          redeemValuePerPoint: 250,
          minimumEligibleTransaction: 50000,
          maximumRedemptionPercentage: 20,
        );

        await provider.write(saved);

        // When:
        controller.load();

        // Then:
        expect(controller.configuration.value.toMap(), saved.toMap());
        expect(repository.loyaltyConfiguration.toMap(), saved.toMap());
      },
    );

    test(
      'Given a staff user is signed in, '
      'When staff attempts to change loyalty rules, '
      'Then the change is rejected and stored rules remain unchanged',
      () async {
        // Given:
        await repository.login(
          email: 'staff@demo.local',
          password: 'staff123',
        );

        final attempted = LoyaltyConfiguration.defaults.copyWith(
          spendPerPoint: 50000,
        );

        // When:
        final saved = await controller.save(attempted);

        // Then:
        expect(saved, isFalse);
        expect(
          controller.errorMessage.value,
          contains('Only an owner'),
        );
        expect(
          provider.read().toMap(),
          LoyaltyConfiguration.defaults.toMap(),
        );
      },
    );

    test(
      'Given an owner is signed in, '
      'When valid loyalty rules are saved, '
      'Then storage controller and repository update together',
      () async {
        // Given:
        await repository.login(
          email: 'owner@demo.local',
          password: 'owner123',
        );

        final updated = LoyaltyConfiguration.defaults.copyWith(
          spendPerPoint: 30000,
          redeemValuePerPoint: 300,
          minimumEligibleTransaction: 60000,
          maximumRedemptionPercentage: 30,
        );

        // When:
        final saved = await controller.save(updated);

        // Then:
        expect(saved, isTrue);
        expect(provider.read().toMap(), updated.toMap());
        expect(controller.configuration.value.toMap(), updated.toMap());
        expect(repository.loyaltyConfiguration.toMap(), updated.toMap());
        expect(controller.errorMessage.value, isEmpty);
        expect(controller.saving.value, isFalse);
      },
    );
  });
}
