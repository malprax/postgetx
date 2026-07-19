import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';
import 'package:postgetx/app/modules/settings/widgets/capital_protection_configuration_form.dart';

void main() {
  testWidgets(
    'Given a presentational capital form, '
    'When valid rules are submitted, '
    'Then the callback receives them without Hive or GetX',
    (tester) async {
      CapitalProtectionConfiguration? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CapitalProtectionConfigurationForm(
              initialConfiguration: CapitalProtectionConfiguration.defaults,
              onSave: (configuration) async {
                submitted = configuration;
                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(
          const ValueKey('capital-operational-reserve'),
        ),
        '35',
      );
      await tester.enterText(
        find.byKey(
          const ValueKey('capital-minimum-cash-buffer'),
        ),
        '250000',
      );
      await tester.tap(
        find.byKey(
          const ValueKey(
            'save-capital-protection-configuration',
          ),
        ),
      );
      await tester.pump();

      expect(submitted?.operationalReservePercentage, 35);
      expect(submitted?.minimumCashBuffer, 250000);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Given unsafe capital rules, '
    'When save is pressed, Then validation blocks submission',
    (tester) async {
      var submissions = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CapitalProtectionConfigurationForm(
              initialConfiguration: CapitalProtectionConfiguration.defaults,
              onSave: (_) async {
                submissions++;
                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(
          const ValueKey('capital-operational-reserve'),
        ),
        '90',
      );
      await tester.enterText(
        find.byKey(
          const ValueKey('capital-minimum-cash-buffer'),
        ),
        '-1',
      );
      await tester.tap(
        find.byKey(
          const ValueKey(
            'save-capital-protection-configuration',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'Reserve percentage must be between 0 and 80.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Minimum cash buffer cannot be negative.',
        ),
        findsOneWidget,
      );
      expect(submissions, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
