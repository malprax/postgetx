import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';
import 'package:postgetx/app/data/providers/local/capital_protection_configuration_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

void main() {
  late Directory directory;
  late Box<dynamic> dataBox;
  late Box<dynamic> preferenceBox;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'capital-configuration-test',
    );
    Hive.init(directory.path);
    dataBox = await Hive.openBox<dynamic>(
      'data-${DateTime.now().microsecondsSinceEpoch}',
    );
    preferenceBox = await Hive.openBox<dynamic>(
      'preferences-${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await dataBox.close();
    await preferenceBox.close();
    await directory.delete(recursive: true);
  });

  test(
    'Given valid capital rules, When stored offline, '
    'Then they restore exactly',
    () async {
      final provider = CapitalProtectionConfigurationProvider(preferenceBox);
      const configuration = CapitalProtectionConfiguration(
        operationalReservePercentage: 35,
        minimumCashBuffer: 250000,
      );

      await provider.write(configuration);
      final restored = provider.read();

      expect(restored.operationalReservePercentage, 35);
      expect(restored.minimumCashBuffer, 250000);
    },
  );

  test(
    'Given configured reserve and buffer, '
    'When capital health and withdrawal risk are calculated, '
    'Then repository uses the configured rules',
    () async {
      final repository = LocalHiveRepository.forBox(dataBox);
      await repository.resetDemoData();
      await repository.login(
        email: 'owner@demo.local',
        password: 'owner123',
      );

      const configuration = CapitalProtectionConfiguration(
        operationalReservePercentage: 50,
        minimumCashBuffer: 1000,
      );

      repository.applyCapitalProtectionConfiguration(
        configuration,
      );

      final health = await repository.getCapitalHealthSummary();
      final expectedSafe =
          health.grossMargin * .5 > 1000 ? health.grossMargin * .5 - 1000 : 0.0;

      expect(health.operationalReserve, health.grossMargin * .5);
      expect(health.safeToUseRemaining, expectedSafe);

      final withdrawal = await repository.recordOwnerWithdrawal(
        amount: expectedSafe + 500,
        reason: 'Configured risk boundary',
      );

      expect(withdrawal.isSuccess, isTrue);
      expect(withdrawal.value!.protectedCapitalImpact, 500);
    },
  );

  test(
    'Given invalid stored configuration, '
    'When it is restored, Then safe defaults are used',
    () async {
      await preferenceBox.put(
        'capitalProtectionConfiguration',
        {
          'operationalReservePercentage': 99,
          'minimumCashBuffer': -1,
        },
      );

      final restored = CapitalProtectionConfigurationProvider(
        preferenceBox,
      ).read();

      expect(
        restored.operationalReservePercentage,
        CapitalProtectionConfiguration.defaults.operationalReservePercentage,
      );
      expect(
        restored.minimumCashBuffer,
        CapitalProtectionConfiguration.defaults.minimumCashBuffer,
      );
    },
  );
}
