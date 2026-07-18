import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/providers/local/loyalty_tier_rules_provider.dart';

void main() {
  group('Feature: Loyalty tier rules persist offline', () {
    late Directory directory;
    late Box<dynamic> box;
    late LoyaltyTierRulesProvider provider;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'loyalty-tier-rules-',
      );

      Hive.init(directory.path);

      box = await Hive.openBox<dynamic>(
        'loyalty-tier-rules-${DateTime.now().microsecondsSinceEpoch}',
      );

      provider = LoyaltyTierRulesProvider(box);
    });

    tearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    test(
      'Given tier rules have never been configured, '
      'When offline settings are loaded, '
      'Then safe defaults are returned',
      () {
        // Given: no stored tier rules.

        // When:
        final rules = provider.read();

        // Then:
        expect(rules.toMap(), LoyaltyTierRules.defaults.toMap());
        expect(rules.isValid, isTrue);
      },
    );

    test(
      'Given an owner saves valid tier thresholds and rewards, '
      'When settings are loaded again, '
      'Then all rules remain available offline',
      () async {
        // Given:
        const rules = LoyaltyTierRules(
          silverMinimumSpend: 2000000,
          goldMinimumSpend: 8000000,
          memberPointsMultiplier: 1,
          silverPointsMultiplier: 1.2,
          goldPointsMultiplier: 1.6,
        );

        // When:
        await provider.write(rules);
        final restored = provider.read();

        // Then:
        expect(restored.toMap(), rules.toMap());
        expect(restored.resolve(3000000), LoyaltyTier.silver);
        expect(restored.resolve(9000000), LoyaltyTier.gold);
      },
    );

    test(
      'Given unsafe tier rewards are submitted, '
      'When persistence is attempted, '
      'Then storage rejects them and safe defaults remain',
      () async {
        // Given:
        const unsafe = LoyaltyTierRules(
          silverMinimumSpend: 5000000,
          goldMinimumSpend: 1000000,
          memberPointsMultiplier: 1,
          silverPointsMultiplier: 3,
          goldPointsMultiplier: 4,
        );

        // When / Then:
        expect(
          () => provider.write(unsafe),
          throwsA(isA<FormatException>()),
        );

        expect(
          provider.read().toMap(),
          LoyaltyTierRules.defaults.toMap(),
        );
      },
    );

    test(
      'Given corrupted tier data exists locally, '
      'When settings are restored, '
      'Then invalid data falls back to safe defaults',
      () async {
        // Given:
        await box.put('loyaltyTierRules', {
          'silverMinimumSpend': 5000000,
          'goldMinimumSpend': 1000000,
          'memberPointsMultiplier': 1,
          'silverPointsMultiplier': 9,
          'goldPointsMultiplier': 10,
        });

        // When:
        final restored = provider.read();

        // Then:
        expect(
          restored.toMap(),
          LoyaltyTierRules.defaults.toMap(),
        );
      },
    );
  });
}
