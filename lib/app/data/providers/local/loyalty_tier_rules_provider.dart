import 'package:hive_flutter/hive_flutter.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';

class LoyaltyTierRulesProvider {
  LoyaltyTierRulesProvider(this._box);

  static const boxName = 'retail_pos_preferences';
  static const _key = 'loyaltyTierRules';

  final Box<dynamic> _box;

  static Future<LoyaltyTierRulesProvider> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return LoyaltyTierRulesProvider(box);
  }

  LoyaltyTierRules read() {
    final stored = _box.get(_key);

    if (stored is! Map) {
      return LoyaltyTierRules.defaults;
    }

    return LoyaltyTierRules.fromMap(stored);
  }

  Future<void> write(LoyaltyTierRules rules) async {
    final errors = rules.validate();

    if (errors.isNotEmpty) {
      throw FormatException(errors.join(' '));
    }

    await _box.put(_key, rules.toMap());
  }
}
