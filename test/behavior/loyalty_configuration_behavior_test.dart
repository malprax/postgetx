import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/providers/local/loyalty_configuration_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Box<dynamic> box;
  late LoyaltyConfigurationProvider provider;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'loyalty-configuration-test',
    );
    Hive.init(directory.path);

    box = await Hive.openBox<dynamic>(
      'loyalty-${DateTime.now().microsecondsSinceEpoch}',
    );
    provider = LoyaltyConfigurationProvider(box);
  });

  tearDown(() async {
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'Given loyalty has never been configured, '
    'When settings are loaded, '
    'Then safe defaults are returned',
    () {
      // Given: no stored configuration exists.

      // When:
      final configuration = provider.read();

      // Then:
      expect(configuration.isEnabled, isTrue);
      expect(configuration.spendPerPoint, 10000);
      expect(configuration.redeemValuePerPoint, 100);
      expect(configuration.minimumEligibleTransaction, 10000);
      expect(configuration.maximumRedemptionPercentage, 50);
      expect(configuration.isValid, isTrue);
    },
  );

  test(
    'Given an owner saves valid loyalty rules, '
    'When settings are loaded again, '
    'Then the offline configuration is preserved',
    () async {
      // Given:
      final configuration = LoyaltyConfiguration.defaults.copyWith(
        spendPerPoint: 20000,
        redeemValuePerPoint: 200,
        minimumEligibleTransaction: 50000,
        maximumRedemptionPercentage: 25,
      );

      // When:
      await provider.write(configuration);
      final restored = provider.read();

      // Then:
      expect(restored.spendPerPoint, 20000);
      expect(restored.redeemValuePerPoint, 200);
      expect(restored.minimumEligibleTransaction, 50000);
      expect(restored.maximumRedemptionPercentage, 25);
    },
  );

  test(
    'Given unsafe loyalty values, '
    'When the owner attempts to save them, '
    'Then persistence is rejected and defaults remain protected',
    () async {
      // Given:
      const unsafe = LoyaltyConfiguration(
        isEnabled: true,
        spendPerPoint: 100,
        redeemValuePerPoint: 100,
        minimumEligibleTransaction: -1,
        maximumRedemptionPercentage: 150,
      );

      // When / Then:
      expect(
        () => provider.write(unsafe),
        throwsA(isA<FormatException>()),
      );

      expect(provider.read().toMap(), LoyaltyConfiguration.defaults.toMap());
    },
  );
}
