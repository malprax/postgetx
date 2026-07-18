import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';

class LoyaltyConfigurationProvider {
  LoyaltyConfigurationProvider(this._box);

  static const boxName = 'retail_pos_preferences';
  static const _key = 'loyaltyConfiguration';

  final Box<dynamic> _box;

  static Future<LoyaltyConfigurationProvider> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return LoyaltyConfigurationProvider(box);
  }

  LoyaltyConfiguration read() {
    final stored = _box.get(_key);

    if (stored is! Map) {
      return LoyaltyConfiguration.defaults;
    }

    final configuration = LoyaltyConfiguration.fromMap(stored);

    return configuration.isValid
        ? configuration
        : LoyaltyConfiguration.defaults;
  }

  Future<void> write(LoyaltyConfiguration configuration) async {
    final errors = configuration.validate();

    if (errors.isNotEmpty) {
      throw FormatException(errors.join(' '));
    }

    await _box.put(_key, configuration.toMap());
  }
}
