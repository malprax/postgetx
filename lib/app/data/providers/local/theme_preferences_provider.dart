import 'package:hive_flutter/hive_flutter.dart';

class ThemePreferencesProvider {
  ThemePreferencesProvider(this._box);

  static const boxName = 'retail_pos_preferences';
  static const _key = 'themePreference';

  final Box<dynamic> _box;

  static Future<ThemePreferencesProvider> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return ThemePreferencesProvider(box);
  }

  String read({required String fallback}) {
    return _box.get(_key, defaultValue: fallback)?.toString() ?? fallback;
  }

  Future<void> write(String value) => _box.put(_key, value);
}
