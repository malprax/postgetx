import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';

class CapitalProtectionConfigurationProvider {
  CapitalProtectionConfigurationProvider(this._box);

  static const boxName = 'retail_pos_preferences';
  static const _key = 'capitalProtectionConfiguration';

  final Box<dynamic> _box;

  static Future<CapitalProtectionConfigurationProvider> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return CapitalProtectionConfigurationProvider(box);
  }

  CapitalProtectionConfiguration read() {
    final stored = _box.get(_key);

    if (stored is! Map) {
      return CapitalProtectionConfiguration.defaults;
    }

    return CapitalProtectionConfiguration.fromMap(stored);
  }

  Future<void> write(
    CapitalProtectionConfiguration configuration,
  ) async {
    final errors = configuration.validate();

    if (errors.isNotEmpty) {
      throw FormatException(errors.join(' '));
    }

    await _box.put(_key, configuration.toMap());
  }
}
